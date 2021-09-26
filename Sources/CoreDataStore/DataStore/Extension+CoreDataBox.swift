//
//  Extension+CoreDataBox.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

public extension CoreDataDataStore where T: ManagedObjectWrapper {
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value.toObject(), ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return value
    }

    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values.map { $0.toObject() }, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return values
    }

    func deleteSync(_ value: T) throws {
        try Helper.instance.deleteSync(value.toObject(), managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }

    func deleteSync(_ values: [T]) throws {
        try Helper.instance.deleteSync(values.map { $0.toObject() }, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }

    func getList(options: DataStoreFetchOption) throws -> ListDTO<T> {
        let listResult = try Helper.instance.getList(
            of: T.Object.self, options: options, ttl: ttl,
            managedContext: configuration.managedObjectContext,
            metaManagedContext: configuration.metaManagedObjectContext
        )

        let before = listResult.previous.map(T.init)
        let after = listResult.next.map(T.init)
        let pagination = make(total: listResult.total, page: listResult.page, size: listResult.size, previous: before, next: after)

        return .init(data: listResult.items.map(T.init), pagination: pagination)
    }

    func eraseSync() throws {
        try Helper.instance.eraseSync(of: T.Object.self, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }
}

public extension CoreDataIdentifiableDataStore where T: ManagedObjectWrapper {
    func lastID() throws -> T.ID {
        let value = try Helper.instance.getLastObject(of: T.Object.self, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return T(object: value).id
    }
}

public extension CoreDataIdentifiableDataStore where T: CoreDataIdentifiable, T: ManagedObjectWrapper {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T {
        guard let idArg = id as? CVarArg else {
            throw DataStoreError.lookForIDFailure
        }

        let fetchRequest = NSFetchRequest<T.Object>(entityName: String(describing: T.Object.self))
        fetchRequest.predicate = NSPredicate(format: "%K = %@", T.keyPathForID(), idArg)
        let results = try configuration.managedObjectContext.fetch(fetchRequest)
        guard let value = results.first else {
            throw DataStoreError.notFound
        }

        if ttl <= 0 {
            return T(object: value)
        }

        let meta = try Helper.instance.getMeta(forObject: value, metaManagedContext: configuration.metaManagedObjectContext)
        if meta.isValid {
            return T(object: value)
        }

        throw DataStoreError.lookForIDFailure
    }
}
