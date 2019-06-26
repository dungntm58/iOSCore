//
//  Helper.swift
//  CoreCleanSwiftCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreCleanSwiftBase

struct Helper {
    struct ListResult<T> {
        let before: T?
        let after: T?
        let total: Int
        let size: Int
        let items: [T]

        init() {
            self.init(items: [], total: 0, size: 0)
        }

        init(items: [T], total: Int, size: Int) {
            self.items = items
            self.before = nil
            self.after = nil
            self.total = total
            self.size = size
        }

        init(items: [T], before: T?, after: T?, total: Int, size: Int) {
            self.items = items
            self.before = before
            self.after = after
            self.total = total
            self.size = size
        }
    }

    static let instance = Helper()

    private init() {}

    func saveSync(_ value: NSManagedObject, ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        managedContext.insert(value)
        try managedContext.save()

        let urlRepresentation = value.objectID.uriRepresentation().absoluteString
        let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(MetaObjectEntity.objectClassName), value.objectID.entity.managedObjectClassName, #keyPath(MetaObjectEntity.entityObjectID), urlRepresentation)
        let result = try metaManagedContext.fetch(metaFetchRequest)
        if let result = result.first {
            result.ttl = ttl
            result.localUpdatedTimestamp = Date().timeIntervalSince1970
        } else if let entity = NSEntityDescription.entity(forEntityName: "MetaObjectEntity", in: metaManagedContext) {
            let newMeta = MetaObjectEntity(entity: entity, insertInto: metaManagedContext)
            newMeta.entityObjectID = urlRepresentation
            newMeta.objectClassName = value.objectID.entity.managedObjectClassName
            newMeta.localUpdatedTimestamp = Date().timeIntervalSince1970
            newMeta.ttl = ttl

            metaManagedContext.insert(newMeta)
        }
        try metaManagedContext.save()
    }

    func saveSync(_ values: [NSManagedObject], ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        for value in values {
            managedContext.insert(value)
        }
        try managedContext.save()

        for value in values {
            let urlRepresentation = value.objectID.uriRepresentation().absoluteString
            let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
            metaFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(MetaObjectEntity.objectClassName), value.objectID.entity.managedObjectClassName, #keyPath(MetaObjectEntity.entityObjectID), urlRepresentation)
            let result = try metaManagedContext.fetch(metaFetchRequest)
            if let result = result.first {
                result.ttl = ttl
                result.localUpdatedTimestamp = Date().timeIntervalSince1970
            } else if let entity = NSEntityDescription.entity(forEntityName: "MetaObjectEntity", in: metaManagedContext) {
                let newMeta = MetaObjectEntity(entity: entity, insertInto: metaManagedContext)
                newMeta.entityObjectID = urlRepresentation
                newMeta.objectClassName = value.objectID.entity.managedObjectClassName
                newMeta.localUpdatedTimestamp = Date().timeIntervalSince1970
                newMeta.ttl = ttl

                metaManagedContext.insert(newMeta)
            }
        }

        try metaManagedContext.save()
    }

    func deleteSync(_ value: NSManagedObject, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        let urlRepresentation = value.objectID.uriRepresentation().absoluteString
        let className = value.objectID.entity.managedObjectClassName!

        managedContext.delete(value)
        try managedContext.save()

        let metaFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(MetaObjectEntity.objectClassName), className, #keyPath(MetaObjectEntity.entityObjectID), urlRepresentation)
        let metaDeleteRequest = NSBatchDeleteRequest(fetchRequest: metaFetchRequest)

        try metaManagedContext.execute(metaDeleteRequest)
        try metaManagedContext.save()
    }

    func getList<T>(of type: T.Type, options: DataStoreFetchOption, ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws -> ListResult<T> where T: NSManagedObject {
        var list: [T]
        let after: T?
        let before: T?
        let totalItems: Int
        let size: Int
        let expiredObjectIDs: [String]

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        if try managedContext.count(for: fetchRequest) <= 0 {
            return ListResult<T>(items: [], total: 0, size: 0)
        }

        switch options {
        case .predicate(let predicate, let count, let sorting, let validate):
            if ttl > 0, validate {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
                #if DEBUG
                Swift.print("Expired Object IDs:", expiredObjectIDs)
                #endif
                let ejectionPredicate = NSPredicate(format: "NOT (SELF IN %@)", expiredObjectIDs.compactMap { managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: $0)!) })
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, ejectionPredicate].compactMap { $0 })
            } else {
                expiredObjectIDs = []
                fetchRequest.predicate = predicate
            }
            fetchRequest.predicate = predicate
            size = count
            before = nil

            switch sorting {
            case .asc(let property):
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: property, ascending: true)]
            case .desc(let property):
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: property, ascending: false)]
            case .automatic:
                break
            }

            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return ListResult<T>()
            }

            if count > 0 {
                if totalItems <= count {
                    fetchRequest.fetchBatchSize = totalItems
                    list = try managedContext.fetch(fetchRequest)
                } else {
                    fetchRequest.fetchBatchSize = min(count + 1, totalItems)
                    list = try managedContext.fetch(fetchRequest)
                }
            } else {
                list = try managedContext.fetch(fetchRequest)
            }

            if totalItems > count {
                after = list.removeLast()
            } else {
                after = nil
            }
        case .page(let page, let count, let predicate, let sorting, let validate):
            if ttl > 0, validate {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
                #if DEBUG
                Swift.print("Expired Object IDs:", expiredObjectIDs)
                #endif
                let ejectionPredicate = NSPredicate(format: "NOT (SELF IN %@)", expiredObjectIDs.compactMap { managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: $0)!) })
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, ejectionPredicate].compactMap { $0 })
            } else {
                expiredObjectIDs = []
                fetchRequest.predicate = predicate
            }
            size = count
            switch sorting {
            case .asc(let property):
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: property, ascending: true)]
            case .desc(let property):
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: property, ascending: false)]
            case .automatic:
                break
            }

            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return ListResult<T>()
            }
            if page < 0 {
                throw DataStoreError.invalidParam("page")
            }

            if size < 0 {
                throw DataStoreError.invalidParam("size")
            } else if size == 0 {
                list = try managedContext.fetch(fetchRequest)
                after = nil
                before = nil
                break
            }

            let startIndex = page * size
            let endIndex = (page + 1) * size - 1
            if endIndex < 0 || endIndex < startIndex {
                throw DataStoreError.invalidParam("page, size")
            }

            let outStartIndex = max(startIndex - 1, 0)
            let outEndIndex = min(endIndex + 1, totalItems - 1)

            fetchRequest.fetchOffset = outStartIndex
            fetchRequest.fetchBatchSize = outEndIndex - outStartIndex + 1
            list = try managedContext.fetch(fetchRequest)

            if startIndex == 0 {
                before = nil
            } else {
                before = list.removeFirst()
            }

            if endIndex >= totalItems - 1 {
                after = nil
            } else {
                after = list.removeLast()
            }
        case .automatic:
            before = nil
            size = 10
            if ttl > 0 {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
                #if DEBUG
                Swift.print("Expired Object IDs:", expiredObjectIDs)
                #endif
                let ejectionPredicate = NSPredicate(format: "NOT (SELF IN %@)", expiredObjectIDs.compactMap { managedContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: $0)!) })
                fetchRequest.predicate = ejectionPredicate
            } else {
                expiredObjectIDs = []
            }
            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return ListResult<T>()
            }

            if totalItems <= size {
                after = nil
                fetchRequest.fetchBatchSize = size
                list = try managedContext.fetch(fetchRequest)
            } else {
                fetchRequest.fetchBatchSize = size + 1
                let outOfBoundResult = try managedContext.fetch(fetchRequest)
                list = Array(outOfBoundResult.prefix(size))
                after = outOfBoundResult.last
            }
        }

        return ListResult<T>(items: list, before: before, after: after, total: totalItems, size: size)
    }

    func eraseSync<T>(of type: T.Type, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws where T: NSManagedObject {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try managedContext.execute(deleteRequest)

        let metaFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(MetaObjectEntity.objectClassName), String(describing: type))
        let metaDeleteRequest = NSBatchDeleteRequest(fetchRequest: metaFetchRequest)

        try metaManagedContext.execute(metaDeleteRequest)
        try metaManagedContext.save()
    }

    func getLastObject<T>(of type: T.Type, ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws -> T where T: NSManagedObject {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        let count = try managedContext.count(for: fetchRequest)
        if count <= 0 {
            throw DataStoreError.lookForIDFailure
        }

        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = count - 1
        let results = try managedContext.fetch(fetchRequest)
        guard let value = results.first else {
            throw DataStoreError.notFound
        }

        if ttl <= 0 {
            return value
        }

        let meta = try getMeta(forObject: value, metaManagedContext: metaManagedContext)
        if meta.isValid {
            return value
        }

        throw DataStoreError.notFound
    }

    func getMeta(forObject object: NSManagedObject, metaManagedContext: NSManagedObjectContext) throws -> MetaObjectEntity {
        let urlRepresentation = object.objectID.uriRepresentation().absoluteString
        let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(MetaObjectEntity.objectClassName), object.objectID.entity.managedObjectClassName, #keyPath(MetaObjectEntity.entityObjectID), urlRepresentation)
        let result = try metaManagedContext.fetch(metaFetchRequest)
        if let result = result.first {
            return result
        }

        throw DataStoreError.notFound
    }

    func getExpiredObjectIDs(ttl: TimeInterval, of type: AnyClass, metaManagedContext: NSManagedObjectContext) throws -> [String] {
        let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
        let timestamp = Date().timeIntervalSince1970 - ttl
        metaFetchRequest.predicate = NSPredicate(format: "%K = %@ AND %K < %f", #keyPath(MetaObjectEntity.objectClassName), String(describing: type), #keyPath(MetaObjectEntity.localUpdatedTimestamp), timestamp)
        let result = try metaManagedContext.fetch(metaFetchRequest)
        return result.compactMap { $0.entityObjectID }
    }
}
