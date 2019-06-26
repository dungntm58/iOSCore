//
//  Extension+Realm.swift
//  CoreCleanSwiftRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreCleanSwiftBase

public extension RealmDataStore where T: Object {
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value, ttl: ttl, realm: realm)
        return value
    }

    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values, ttl: ttl, realm: realm)
        return values
    }

    func deleteSync(_ value: T) throws -> Bool {
        try Helper.instance.deleteSync(value, realm: realm)
        return true
    }

    func getList(options: DataStoreFetchOption) throws -> ListResponse<T> {
        let listResult = try Helper.instance.getList(of: T.self, options: options, ttl: ttl, realm: realm)
        let pagination = make(total: listResult.total, size: listResult.size, before: listResult.before, after: listResult.after)

        return ListResponse<T>(data: listResult.items, pagination: pagination)
    }

    func eraseSync() throws -> Bool {
        try Helper.instance.eraseSync(of: T.self, realm: realm)
        return true
    }
}

public extension RealmIdentifiableDataStore where T: Object {
    func getSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> T {
        guard let value = realm.object(ofType: T.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }

        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }

        return value
    }

    func lastID() throws -> T.IDType {
        if let lastId = realm.objects(T.self).last?.id {
            return lastId
        }

        throw DataStoreError.lookForIDFailure
    }
}
