//
//  Helper.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

struct ListResult<T> {
    let previous: T?
    let next: T?
    let total: Int
    let page: Int
    let size: Int
    let items: [T]

    init() {
        self.init(items: [], total: 0, page: 0, size: 0)
    }

    init(items: [T], total: Int, page: Int, size: Int) {
        self.items = items
        self.previous = nil
        self.next = nil
        self.total = total
        self.page = page
        self.size = size
    }

    init(items: [T], previous: T?, next: T?, total: Int, page: Int, size: Int) {
        self.items = items
        self.previous = previous
        self.next = next
        self.total = total
        self.page = page
        self.size = size
    }
}

// swiftlint:disable type_body_length file_length
struct Helper {
    static let instance = Helper()

    private init() {}

    private func checkObjectExists(value: NSManagedObject, managedContext: NSManagedObjectContext) throws -> Bool {
        guard let entityName = value.entity.name else { return false }
        let existRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        existRequest.predicate = .init(format: "SELF.objectID == %@", value.objectID)
        let count = try managedContext.count(for: existRequest)
        return count > 0
    }

    func saveSync(_ value: NSManagedObject, ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        if try !checkObjectExists(value: value, managedContext: managedContext) {
            managedContext.insert(value)
        }
        if managedContext.hasChanges {
            try managedContext.save()
        }
        let urlRepresentation = value.objectID.uriRepresentation().absoluteString
        let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(MetaObjectEntity.objectClassName),
            value.objectID.entity.managedObjectClassName,
            #keyPath(MetaObjectEntity.entityObjectID),
            urlRepresentation
        )
        let result = try metaManagedContext.fetch(metaFetchRequest)
        if let result = result.first {
            result.ttl = ttl
            result.localUpdatedTimestamp = Date().timeIntervalSince1970
        } else if let entity = NSEntityDescription.entity(forEntityName: "MetaObjectEntity", in: metaManagedContext) {
            let newMeta = MetaObjectEntity(entity: entity, insertInto: nil)
            newMeta.entityObjectID = urlRepresentation
            newMeta.objectClassName = value.objectID.entity.managedObjectClassName
            newMeta.localUpdatedTimestamp = Date().timeIntervalSince1970
            newMeta.ttl = ttl

            metaManagedContext.insert(newMeta)
        }
        if metaManagedContext.hasChanges {
            try metaManagedContext.save()
        }
    }

    func saveSync(_ values: [NSManagedObject], ttl: TimeInterval, managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        try values
            .filter { try !checkObjectExists(value: $0, managedContext: managedContext) }
            .forEach(managedContext.insert(_:))
        if managedContext.hasChanges {
            try managedContext.save()
        }

        for value in values {
            let urlRepresentation = value.objectID.uriRepresentation().absoluteString
            let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
            metaFetchRequest.predicate = NSPredicate(
                format: "%K = %@ AND %K = %@",
                #keyPath(MetaObjectEntity.objectClassName),
                value.objectID.entity.managedObjectClassName,
                #keyPath(MetaObjectEntity.entityObjectID),
                urlRepresentation
            )
            let result = try metaManagedContext.fetch(metaFetchRequest)
            if let result = result.first {
                result.ttl = ttl
                result.localUpdatedTimestamp = Date().timeIntervalSince1970
            } else if let entity = NSEntityDescription.entity(forEntityName: "MetaObjectEntity", in: metaManagedContext) {
                let newMeta = MetaObjectEntity(entity: entity, insertInto: nil)
                newMeta.entityObjectID = urlRepresentation
                newMeta.objectClassName = value.objectID.entity.managedObjectClassName
                newMeta.localUpdatedTimestamp = Date().timeIntervalSince1970
                newMeta.ttl = ttl

                metaManagedContext.insert(newMeta)
            }
        }
        if metaManagedContext.hasChanges {
            try metaManagedContext.save()
        }
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

    func deleteSync(_ values: [NSManagedObject], managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext) throws {
        let urlRepresentations = values.map { $0.objectID.uriRepresentation().absoluteString }
        let classNames = values.map { $0.objectID.entity.managedObjectClassName! }

        values.forEach(managedContext.delete)
        try managedContext.save()

        let metaFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MetaObjectEntity")
        metaFetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: zip(classNames, urlRepresentations)
                .map { className, url in
                    NSPredicate(format: "%K = %@ AND %K = %@", #keyPath(MetaObjectEntity.objectClassName), className, #keyPath(MetaObjectEntity.entityObjectID), url)
                }
        )
        let metaDeleteRequest = NSBatchDeleteRequest(fetchRequest: metaFetchRequest)

        try metaManagedContext.execute(metaDeleteRequest)
        try metaManagedContext.save()
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func getList<T>(
        of type: T.Type,
        options: DataStoreFetchOption,
        ttl: TimeInterval,
        managedContext: NSManagedObjectContext, metaManagedContext: NSManagedObjectContext
    ) throws -> ListResult<T> where T: NSManagedObject {
        var list: [T]
        let after: T?
        let before: T?
        let totalItems: Int
        let size: Int
        let currentPage: Int
        let expiredObjectIDs: [String]

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        if try managedContext.count(for: fetchRequest) <= 0 {
            return .init()
        }

        switch options {
        case .predicate(let predicate, let count, let sorting, let validate):
            if ttl > 0, validate {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
#if !RELEASE && !PRODUCTION
                Swift.print("Expired Object IDs:", expiredObjectIDs)
#endif
                let ejectionPredicate = NSPredicate(
                    format: "NOT (SELF IN %@)",
                    expiredObjectIDs.compactMap {
                        managedContext.persistentStoreCoordinator?
                            .managedObjectID(forURIRepresentation: URL(string: $0)!)
                    }
                )
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, ejectionPredicate].compactMap { $0 })
            } else {
                expiredObjectIDs = []
                fetchRequest.predicate = predicate
            }
            fetchRequest.predicate = predicate
            size = count
            before = nil
            currentPage = 0

            fetchRequest.sortDescriptors = sorting.toSortDescriptors()

            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return .init()
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
            currentPage = page
            if ttl > 0, validate {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
#if !RELEASE && !PRODUCTION
                Swift.print("Expired Object IDs:", expiredObjectIDs)
#endif
                let ejectionPredicate = NSPredicate(
                    format: "NOT (SELF IN %@)",
                    expiredObjectIDs.compactMap {
                        managedContext.persistentStoreCoordinator?
                            .managedObjectID(forURIRepresentation: URL(string: $0)!)
                    }
                )
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, ejectionPredicate].compactMap { $0 })
            } else {
                expiredObjectIDs = []
                fetchRequest.predicate = predicate
            }
            size = count

            fetchRequest.sortDescriptors = sorting.toSortDescriptors()

            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return .init()
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
            currentPage = 0
            before = nil
            size = 10
            if ttl > 0 {
                expiredObjectIDs = try getExpiredObjectIDs(ttl: ttl, of: type, metaManagedContext: metaManagedContext)
#if !RELEASE && !PRODUCTION
                Swift.print("Expired Object IDs:", expiredObjectIDs)
#endif
                let ejectionPredicate = NSPredicate(
                    format: "NOT (SELF IN %@)",
                    expiredObjectIDs.compactMap {
                        managedContext.persistentStoreCoordinator?
                            .managedObjectID(forURIRepresentation: URL(string: $0)!)
                    }
                )
                fetchRequest.predicate = ejectionPredicate
            } else {
                expiredObjectIDs = []
            }
            totalItems = try managedContext.count(for: fetchRequest)
            if totalItems == 0 {
                return .init()
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

        return .init(items: list, previous: before, next: after, total: totalItems, page: currentPage, size: size)
    }
    // swiftlint:enable function_body_length cyclomatic_complexity

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
        metaFetchRequest.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(MetaObjectEntity.objectClassName),
            object.objectID.entity.managedObjectClassName,
            #keyPath(MetaObjectEntity.entityObjectID),
            urlRepresentation
        )
        let result = try metaManagedContext.fetch(metaFetchRequest)
        if let result = result.first {
            return result
        }

        throw DataStoreError.notFound
    }

    func getExpiredObjectIDs(ttl: TimeInterval, of type: AnyClass, metaManagedContext: NSManagedObjectContext) throws -> [String] {
        let metaFetchRequest = NSFetchRequest<MetaObjectEntity>(entityName: "MetaObjectEntity")
        let timestamp = Date().timeIntervalSince1970 - ttl
        metaFetchRequest.predicate = NSPredicate(
            format: "%K = %@ AND %K < %f",
            #keyPath(MetaObjectEntity.objectClassName),
            String(describing: type),
            #keyPath(MetaObjectEntity.localUpdatedTimestamp),
            timestamp
        )
        let result = try metaManagedContext.fetch(metaFetchRequest)
        return result.compactMap(\.entityObjectID)
    }
}
// swiftlint:enable type_body_length

extension Array where Element == DataStoreFetchOption.Sorting {
    @inlinable
    func toSortDescriptors() -> [NSSortDescriptor] {
        compactMap { sorting -> NSSortDescriptor? in
            switch sorting {
            case .asc(let property):
                return .init(key: property, ascending: true)
            case .desc(let property):
                return .init(key: property, ascending: false)
            case .automatic:
                return nil
            }
        }
    }
}
