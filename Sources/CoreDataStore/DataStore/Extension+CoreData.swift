//
//  Extension+CoreData.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

public extension CoreDataDataStore where T: NSManagedObject {
    func save(_ value: T) async throws -> T {
        try Helper.instance.saveSync(value, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return value
    }

    func save(_ values: [T]) async throws -> [T] {
        try Helper.instance.saveSync(values, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return values
    }

    func delete(_ value: T) async throws {
        try Helper.instance.deleteSync(value, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }

    func delete(_ values: [T]) async throws {
        try Helper.instance.deleteSync(values, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }

    func getList(options: DataStoreFetchOption) async throws -> ListDTO<T> {
        let listResult = try Helper.instance.getList(
            of: T.self, options: options, ttl: ttl,
            managedContext: configuration.managedObjectContext,
            metaManagedContext: configuration.metaManagedObjectContext
        )
        let pagination = make(total: listResult.total, page: listResult.page, size: listResult.size, previous: listResult.previous, next: listResult.next)
        return .init(data: listResult.items, pagination: pagination)
    }

    func erase() async throws {
        try Helper.instance.eraseSync(of: T.self, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
    }
}

public extension CoreDataIdentifiableDataStore where T: NSManagedObject {
    func lastID() async throws -> T.ID {
        try Helper.instance.getLastObject(of: T.self, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext).id
    }
}

public extension CoreDataIdentifiableDataStore where T: CoreDataIdentifiable, T: NSManagedObject {
    func get(_ id: T.ID, options: DataStoreFetchOption?) async throws -> T {
        guard let idArg = id as? CVarArg else {
            throw DataStoreError.lookForIDFailure
        }

        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = NSPredicate(format: "%K = %@", T.keyPathForID(), idArg)
        let results = try configuration.managedObjectContext.fetch(fetchRequest)
        guard let value = results.first else {
            throw DataStoreError.notFound
        }

        if ttl <= 0 {
            return value
        }

        let meta = try Helper.instance.getMeta(forObject: value, metaManagedContext: configuration.metaManagedObjectContext)
        if meta.isValid {
            return value
        }

        throw DataStoreError.lookForIDFailure
    }
}
