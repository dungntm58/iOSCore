//
//  Extension+RealmBox.swift
//  CoreCleanSwiftRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreCleanSwiftBase

public extension RealmDataStore where T: RealmObjectBox {
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value.core, ttl: ttl, realm: realm)
        return value
    }

    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values.map { $0.core }, ttl: ttl, realm: realm)
        return values
    }

    func deleteSync(_ value: T) throws -> Bool {
        try Helper.instance.deleteSync(value.core, realm: realm)
        return true
    }

    func getList(options: DataStoreFetchOption) throws -> ListResponse<T> {
        let listResult = try Helper.instance.getList(of: T.RealmObject.self, options: options, ttl: ttl, realm: realm)

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
        try Helper.instance.eraseSync(of: T.RealmObject.self, realm: realm)
        return true
    }
}

public extension RealmIdentifiableDataStore where T: RealmObjectBox {
    func getSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> T {
        guard let value = realm.object(ofType: T.RealmObject.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }

        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }

        return T(core: value)
    }

    func lastID() throws -> T.IDType {
        if let value = realm.objects(T.RealmObject.self).last {
            return T(core: value).id
        }
        
        throw DataStoreError.lookForIDFailure
    }
}
