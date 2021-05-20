//
//  Helper.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift
import CoreRepository

struct ListResult<T> {
    let previous: T?
    let next: T?
    let total: Int
    let size: Int
    let items: [T]

    init() {
        self.init(items: [], total: 0, size: 0)
    }

    init(items: [T], total: Int, size: Int) {
        self.items = items
        self.previous = nil
        self.next = nil
        self.total = total
        self.size = size
    }

    init(items: [T], previous: T?, next: T?, total: Int, size: Int) {
        self.items = items
        self.previous = previous
        self.next = next
        self.total = total
        self.size = size
    }
}

struct Helper {

    static let instance = Helper()

    private init() {}

    func saveSync(_ value: Object, ttl: TimeInterval, realm: Realm, update: Realm.UpdatePolicy) throws {
        try realm.write {
            if let expirable = value as? ExpirableObject {
                expirable.localUpdatedDate = Date()
                expirable.ttl = ttl
            }
            realm.add(value, update: update)
        }
    }

    func saveSync(_ values: [Object], ttl: TimeInterval, realm: Realm, update: Realm.UpdatePolicy) throws {
        try realm.write {
            values.compactMap { $0 as? ExpirableObject }.forEach {
                $0.localUpdatedDate = Date()
                $0.ttl = ttl
            }
            realm.add(values, update: update)
        }
    }

    func deleteSync(_ value: Object, realm: Realm) throws {
        try realm.write {
            realm.delete(value)
        }
    }

    func deleteSync(_ values: [Object], realm: Realm) throws {
        try realm.write {
            realm.delete(values)
        }
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func getList<T>(of type: T.Type, options: DataStoreFetchOption, ttl: TimeInterval, realm: Realm) throws -> ListResult<T> where T: Object {
        var list: [T]
        let after: T?
        let before: T?
        let totalItems: Int
        let size: Int

        var results = realm.objects(T.self)
        if results.isEmpty {
            return .init()
        }

        switch options {
        case .predicate(let predicate, let count, let sorting, let validate):
            if type is Expirable, ttl > 0, validate {
                results = results.filter("%K >= %@", #keyPath(ExpirableObject.localUpdatedDate), Date().addingTimeInterval(-ttl) as NSDate)
            }
            results = results.filter(predicate)
            totalItems = results.count
            if totalItems == 0 {
                return .init()
            }
            before = nil
            size = count

            results = results.sorted(by: sorting.toSortDescriptors())

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
                return .init()
            }
            size = count

            results = results.sorted(by: sorting.toSortDescriptors())

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
            if startIndex >= totalItems || endIndex < 0 || endIndex < startIndex {
                throw DataStoreError.invalidParam("page, size")
            }

            let outStartIndex = max(startIndex - 1, 0)
            let outEndIndex = min(endIndex + 1, totalItems - 1)
            if outStartIndex > outEndIndex {
                throw DataStoreError.invalidParam("page, size")
            }
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
                return .init()
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
        return .init(items: list, previous: before, next: after, total: totalItems, size: size)
    }
    // swiftlint:enable function_body_length cyclomatic_complexity

    func eraseSync<T>(of type: T.Type, realm: Realm) throws where T: Object {
        try realm.write {
            realm.delete(realm.objects(type))
        }
    }
}

extension Array where Element == DataStoreFetchOption.Sorting {
    func toSortDescriptors() -> [SortDescriptor] {
        compactMap { sorting -> SortDescriptor? in
            switch sorting {
            case .asc(let property):
                return .init(keyPath: property, ascending: true)
            case .desc(let property):
                return .init(keyPath: property, ascending: false)
            case .automatic:
                return nil
            }
        }
    }
}
