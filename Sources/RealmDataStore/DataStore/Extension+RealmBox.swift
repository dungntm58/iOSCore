//
//  Extension+RealmBox.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import Foundation
import RealmSwift
import CoreRepository
#if canImport(CoreRepositoryDataStore)
import CoreRepositoryDataStore
#endif

public extension RealmDataStore where T: RealmObjectWrapper {
    @discardableResult
    func save(_ value: T) async throws -> T {
        let realm = try getRealm()
        try Helper.instance.saveSync(value.toObject(), ttl: ttl, realm: realm, update: self.updatePolicy)
        return value
    }

    @discardableResult
    func save(_ values: [T]) async throws -> [T] {
        let realm = try getRealm()
        try Helper.instance.saveSync(values.map { $0.toObject() }, ttl: ttl, realm: realm, update: self.updatePolicy)
        return values
    }

    func delete(_ value: T) async throws {
        let realm = try getRealm()
        try Helper.instance.deleteSync(value.toObject(), realm: realm)
    }

    func delete(_ values: [T]) async throws {
        let realm = try getRealm()
        try Helper.instance.deleteSync(values.map { $0.toObject() }, realm: realm)
    }

    func getList(options: DataStoreFetchOption) async throws -> ListDTO<T> {
        let realm = try getRealm()
        let listResult = try Helper.instance.getList(of: T.RealmObject.self, options: options, ttl: ttl, realm: realm)

        let before = listResult.previous.map(T.init)
        let after = listResult.next.map(T.init)
        let pagination = make(total: listResult.total, page: listResult.page, size: listResult.size, previous: before, next: after)
        return .init(data: listResult.items.map(T.init), pagination: pagination)
    }

    func erase() async throws {
        let realm = try getRealm()
        try Helper.instance.eraseSync(of: T.RealmObject.self, realm: realm)
    }
}

public extension RealmIdentifiableDataStore where T: RealmObjectWrapper {
    func get(_ id: T.ID, options: DataStoreFetchOption?) async throws -> T {
        let realm = try getRealm()
        guard let value = realm.object(ofType: T.RealmObject.self, forPrimaryKey: id) else {
            throw DataStoreError.notFound
        }
        if let expirable = value as? Expirable, let expiryDate = expirable.expiryDate, expiryDate < Date() {
            throw DataStoreError.notFound
        }
        return T(object: value)
    }

    func lastID() async throws -> T.ID {
        let realm = try getRealm()
        if let value = realm.objects(T.RealmObject.self).last {
            return T(object: value).id
        }
        throw DataStoreError.lookForIDFailure
    }
}
