//
//  Extension+CoreData.swift
//  CoreCleanSwiftCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreCleanSwiftBase

public extension CoreDataDataStore where T: NSManagedObject {
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return value
    }

    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return values
    }

    func deleteSync(_ value: T) throws -> Bool {
        try Helper.instance.deleteSync(value, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return true
    }

    func getList(options: DataStoreFetchOption) throws -> ListResponse<T> {
        let listResult = try Helper.instance.getList(of: T.self, options: options, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        let pagination = make(total: listResult.total, size: listResult.size, before: listResult.before, after: listResult.after)
        return ListResponse<T>(data: listResult.items, pagination: pagination)
    }

    func eraseSync() throws -> Bool {
        try Helper.instance.eraseSync(of: T.self, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return true
    }
}

public extension CoreDataIdentifiableDataStore where T: NSManagedObject {
    func lastID() throws -> T.IDType {
        return try Helper.instance.getLastObject(of: T.self, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext).id
    }
}

public extension CoreDataIdentifiableDataStore where T: CoreDataIdentifiable, T: NSManagedObject {
    func getSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> T {
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
