//
//  Helper.swift
//  CoreCleanSwiftRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreCleanSwiftBase

struct Helper {
    struct ListResult<T> {
        let before: T?
        let after: T?
        let total: Int
        let size: Int
        let items: [T]

        init() {
            self.init(items: [], total: 0, size: 0)
        }

        init(items: [T], total: Int, size: Int) {
            self.items = items
            self.before = nil
            self.after = nil
            self.total = total
            self.size = size
        }

        init(items: [T], before: T?, after: T?, total: Int, size: Int) {
            self.items = items
            self.before = before
            self.after = after
            self.total = total
            self.size = size
        }
    }

    static let instance = Helper()

    private init() {}

    func saveSync(_ value: Object, ttl: TimeInterval, realm: Realm) throws {
        try realm.write {
            if let expirable = value as? ExpirableObject {
                expirable.localUpdatedDate = Date()
                expirable.ttl = ttl
            }
            realm.add(value, update: true)
        }
    }

    func saveSync(_ values: [Object], ttl: TimeInterval, realm: Realm) throws {
        try realm.write {
            values.compactMap { $0 as? ExpirableObject }.forEach {
                $0.localUpdatedDate = Date()
                $0.ttl = ttl
            }
            realm.add(values, update: true)
        }
    }

    func deleteSync(_ value: Object, realm: Realm) throws {
        try realm.write {
            realm.delete(value)
        }
    }

    func getList<T>(of type: T.Type, options: DataStoreFetchOption, ttl: TimeInterval, realm: Realm) throws -> ListResult<T> where T: Object {
        var list: [T]
        let after: T?
        let before: T?
        let totalItems: Int
        let size: Int

        var results = realm.objects(T.self)
        if results.isEmpty {
            return ListResult<T>()
        }

        switch options {
        case .predicate(let predicate, let count, let sorting, let validate):
            if type is Expirable, ttl > 0, validate {
                results = results.filter("%K >= %@", #keyPath(ExpirableObject.localUpdatedDate), Date().addingTimeInterval(-ttl) as NSDate)
            }
            results = results.filter(predicate)
            totalItems = results.count
            if totalItems == 0 {
                return ListResult<T>()
            }
            before = nil
            size = count

            switch sorting {
            case .asc(let property):
                results = results.sorted(byKeyPath: property, ascending: true)
            case .desc(let property):
                results = results.sorted(byKeyPath: property, ascending: false)
            case .automatic:
                break
            }

            let outOfBoundResults: Slice<Results<T>>
            if count > 0 {
                if results.count <= count {
                    outOfBoundResults = results.prefix(min(count, totalItems))
                } else {
                    outOfBoundResults = results.prefix(min(count + 1, totalItems))
                }
            } else {
                outOfBoundResults = results[0...]
            }
            list = Array(outOfBoundResults)

            if totalItems > count {
                after = list.removeLast()
            } else {
                after = nil
            }
        case .page(let page, let count, let predicate, let sorting, let validate):
            if type is Expirable, ttl > 0, validate {
                results = results.filter("%K >= %@", #keyPath(ExpirableObject.localUpdatedDate), Date().addingTimeInterval(-ttl) as NSDate)
            }
            if let predicate = predicate {
                results = results.filter(predicate)
            }
            totalItems = results.count
            if totalItems == 0 {
                return ListResult<T>()
            }
            size = count
            switch sorting {
            case .asc(let property):
                results = results.sorted(byKeyPath: property, ascending: true)
            case .desc(let property):
                results = results.sorted(byKeyPath: property, ascending: false)
            case .automatic:
                break
            }

            if page < 0 {
                throw DataStoreError.invalidParam("page")
            }

            if size < 0 {
                throw DataStoreError.invalidParam("size")
            } else if size == 0 {
                before = nil
                after = nil
                list = Array(results)
                break
            }

            let startIndex = page * size
            let endIndex = (page + 1) * size - 1
            if endIndex < 0 || endIndex < startIndex {
                throw DataStoreError.invalidParam("page, size")
            }

            let outStartIndex = max(startIndex - 1, 0)
            let outEndIndex = min(endIndex + 1, totalItems - 1)
            let rawArray = results[outStartIndex...outEndIndex]
            list = Array(rawArray)

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
            if type is Expirable, ttl > 0 {
                results = results.filter("%K >= %@", #keyPath(ExpirableObject.localUpdatedDate), Date().addingTimeInterval(-ttl) as NSDate)
            }
            size = 10
            before = nil
            totalItems = results.count
            if totalItems == 0 {
                return ListResult<T>()
            }
            if totalItems <= size {
                after = nil
                list = Array(results.prefix(min(size, totalItems)))
            } else {
                let outOfBoundResult = results.prefix(min(size + 1, totalItems))
                list = Array(outOfBoundResult[0...size - 1])
                after = outOfBoundResult.last
            }
        }

        return ListResult<T>(items: list, before: before, after: after, total: totalItems, size: size)
    }

    func eraseSync<T>(of type: T.Type, realm: Realm) throws where T: Object {
        try realm.write {
            realm.delete(realm.objects(type))
        }
    }
}
