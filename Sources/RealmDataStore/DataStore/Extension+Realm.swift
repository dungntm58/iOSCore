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
        let realm = try threadSharedRealm()
        try Helper.instance.saveSync(value, ttl: ttl, realm: realm, update: self.updatePolicy)
        return value
    }

    @discardableResult
    func saveSync(_ values: [T]) throws -> [T] {
        let realm = try threadSharedRealm()
        try Helper.instance.saveSync(values, ttl: ttl, realm: realm, update: self.updatePolicy)
        return values
    }

    func deleteSync(_ value: T) throws {
        let realm = try threadSharedRealm()
        try Helper.instance.deleteSync(value, realm: realm)
    }

    func deleteSync(_ values: [T]) throws {
        let realm = try threadSharedRealm()
        try Helper.instance.deleteSync(values, realm: realm)
    }

    func getList(options: DataStoreFetchOption) throws -> ListDTO<T> {
        let realm = try threadSharedRealm()
        let listResult = try Helper.instance.getList(of: T.self, options: options, ttl: ttl, realm: realm)
        let pagination = make(total: listResult.total, page: listResult.page, size: listResult.size, previous: listResult.previous, next: listResult.next)
        return .init(data: listResult.items, pagination: pagination)
    }

    func eraseSync() throws {
        let realm = try threadSharedRealm()
        try Helper.instance.eraseSync(of: T.self, realm: realm)
    }
}

public extension RealmIdentifiableDataStore where T: Object {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T {
        let realm = try threadSharedRealm()
        guard let value = realm.object(ofType: T.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }
        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }
        return value
    }

    func lastID() throws -> T.ID {
        let realm = try threadSharedRealm()
        if let lastId = realm.objects(T.self).last?.id {
            return lastId
        }
        throw DataStoreError.lookForIDFailure
    }
}
