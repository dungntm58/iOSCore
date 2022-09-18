//
//  AnyDataStore.swift
//  CoreRepository-Rx
//
//  Created by Robert on 20/05/2021.
//

import CoreRepository

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

    public func save(_ value: Any) async throws -> Any {
        try await box.save(value)
    }

    public func save(_ values: [Any]) async throws -> [Any] {
        try await box.save(values)
    }

    public func delete(_ value: Any) async throws {
        try await box.delete(value)
    }

    public func delete(_ values: [Any]) async throws {
        try await box.delete(values)
    }

    public func erase() async throws {
        try await box.erase()
    }

    public func getList(options: DataStoreFetchOption) async throws -> ListDTO<Any> {
        try await box.getList(options: options)
    }

    public func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated? {
        box.make(total: total, page: page, size: size, previous: previous, next: next)
    }
}

private protocol AnyDataStoreBox {
    func save(_ value: Any) async throws -> Any
    func save(_ values: [Any]) async throws -> [Any]
    func delete(_ value: Any) async throws
    func delete(_ values: [Any]) async throws
    func erase() async throws
    func getList(options: DataStoreFetchOption) async throws -> ListDTO<Any>
    func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated?
}

// swiftlint:disable force_cast
private struct Box<Base>: AnyDataStoreBox where Base: DataStore {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }

    func save(_ value: Any) async throws -> Any {
        try await base.save(value as! Base.T)
    }

    func save(_ values: [Any]) async throws -> [Any] {
        try await base.save(values as! [Base.T])
    }

    func delete(_ value: Any) async throws {
        try await base.delete(value as! Base.T)
    }

    func delete(_ values: [Any]) async throws {
        try await base.delete(values as! [Base.T])
    }

    func erase() async throws {
        try await base.erase()
    }

    func getList(options: DataStoreFetchOption) async throws -> ListDTO<Any> {
        let listDTO = try await base.getList(options: options)
        return .init(data: listDTO.data, pagination: listDTO.pagination)
    }

    func make(total: Int, page: Int, size: Int, previous: Any?, next: Any?) -> Paginated? {
        base.make(total: total, page: page, size: size, previous: previous as? Base.T, next: next as? Base.T)
    }
}
// swiftlint:enable force_cast
