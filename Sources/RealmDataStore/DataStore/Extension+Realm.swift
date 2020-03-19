//
//  Extension+Realm.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreRepository

public extension RealmDataStore where T: Object {
    @discardableResult
    func saveSync(_ value: T) throws -> T {
        try Helper.instance.saveSync(value, ttl: ttl, realm: realm, update: self.updatePolicy)
        return value
    }

    @discardableResult
    func saveSync(_ values: [T]) throws -> [T] {
        try Helper.instance.saveSync(values, ttl: ttl, realm: realm, update: self.updatePolicy)
        return values
    }

    func deleteSync(_ value: T) throws {
        try Helper.instance.deleteSync(value, realm: realm)
    }

    func getList(options: DataStoreFetchOption) throws -> ListDTO<T> {
        let listResult = try Helper.instance.getList(of: T.self, options: options, ttl: ttl, realm: realm)
        let pagination = make(total: listResult.total, size: listResult.size, previous: listResult.previous, next: listResult.next)
        return .init(data: listResult.items, pagination: pagination)
    }

    func eraseSync() throws {
        try Helper.instance.eraseSync(of: T.self, realm: realm)
    }
}

public extension RealmIdentifiableDataStore where T: Object {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T {
        guard let value = realm.object(ofType: T.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }
        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }
        return value
    }

    func lastID() throws -> T.ID {
        if let lastId = realm.objects(T.self).last?.id {
            return lastId
        }
        throw DataStoreError.lookForIDFailure
    }
}
