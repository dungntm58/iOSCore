//
//  AnyDataStore.swift
//  CoreRepository-Rx
//
//  Created by Robert on 20/05/2021.
//

import FoundationExtInternal

extension DataStore {
    @inlinable
    public func eraseToAny() -> AnyDataStore { .init(self) }
}

public struct AnyDataStore: DataStore {
    // swiftlint:disable type_name
    public typealias T = Any
    // swiftlint:enable type_name

    private let box: AnyDataStoreBox

    @usableFromInline
    init<Store>(_ store: Store) where Store: DataStore {
        if let any = store as? AnyDataStore {
            self = any
        } else {
            box = Box(store)
        }
    }

    public func saveSync(_ value: Any) throws -> Any {
        try box.saveSync(value)
    }

    public func saveSync(_ values: [Any]) throws -> [Any] {
        try box.saveSync(values)
    }

    public func deleteSync(_ value: Any) throws {
        try box.deleteSync(value)
    }

    public func deleteSync(_ values: [Any]) throws {
        try box.deleteSync(values)
    }

    public func eraseSync() throws {
        try box.eraseSync()
    }

    public func getList(options: DataStoreFetchOption) throws -> ListDTO<Any> {
        try box.getList(options: options)
    }

    public func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated? {
        box.make(total: total, page: page, size: size, previous: previous, next: next)
    }
}

private protocol AnyDataStoreBox {
    func saveSync(_ value: Any) throws -> Any
    func saveSync(_ values: [Any]) throws -> [Any]
    func deleteSync(_ value: Any) throws
    func deleteSync(_ values: [Any]) throws
    func eraseSync() throws
    func getList(options: DataStoreFetchOption) throws -> ListDTO<Any>
    func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated?
}

// swiftlint:disable force_cast
private struct Box<Base>: AnyDataStoreBox where Base: DataStore {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }

    func saveSync(_ value: Any) throws -> Any {
        try base.saveSync(value as! Base.T)
    }

    func saveSync(_ values: [Any]) throws -> [Any] {
        try base.saveSync(values as! [Base.T])
    }

    func deleteSync(_ value: Any) throws {
        try base.deleteSync(value as! Base.T)
    }

    func deleteSync(_ values: [Any]) throws {
        try base.deleteSync(values as! [Base.T])
    }

    func eraseSync() throws {
        try base.eraseSync()
    }

    func getList(options: DataStoreFetchOption) throws -> ListDTO<Any> {
        let listDTO = try base.getList(options: options)
        return .init(data: listDTO.data, pagination: listDTO.pagination)
    }

    func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated? {
        base.make(total: total, page: page, size: size, previous: previous as? Base.T, next: next as? Base.T)
    }
}
// swiftlint:enable force_cast
