//
//  Extension+CoreDataBox.swift
//  CoreCleanSwiftCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData
import CoreCleanSwiftBase

public extension CoreDataDataStore where T: ManagedObjectBox {
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value.core, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return value
    }

    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values.map { $0.core }, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return values
    }

    func deleteSync(_ value: T) throws -> Bool {
        try Helper.instance.deleteSync(value.core, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return true
    }

    func getList(options: DataStoreFetchOption) throws -> ListResponse<T> {
        let listResult = try Helper.instance.getList(of: T.Object.self, options: options, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)

        let before: T?
        if let b = listResult.before {
            before = T(core: b)
        } else {
            before = nil
        }

        let after: T?
        if let a = listResult.after {
            after = T(core: a)
        } else {
            after = nil
        }

        let pagination = make(total: listResult.total, size: listResult.size, before: before, after: after)

        return ListResponse<T>(data: listResult.items.map(T.init), pagination: pagination)
    }

    func eraseSync() throws -> Bool {
        try Helper.instance.eraseSync(of: T.Object.self, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return true
    }
}

public extension CoreDataIdentifiableDataStore where T: ManagedObjectBox {
    func lastID() throws -> T.IDType {
        let value = try Helper.instance.getLastObject(of: T.Object.self, ttl: ttl, managedContext: configuration.managedObjectContext, metaManagedContext: configuration.metaManagedObjectContext)
        return T(core: value).id
    }
}

public extension CoreDataIdentifiableDataStore where T: CoreDataIdentifiable, T: ManagedObjectBox {
    func getSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> T {
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
            return T(core: value)
        }

        let meta = try Helper.instance.getMeta(forObject: value, metaManagedContext: configuration.metaManagedObjectContext)
        if meta.isValid {
            return T(core: value)
        }

        throw DataStoreError.lookForIDFailure
    }
}
