//
//  DataStore.swift
//  iOSCore
//
//  Created by Robert on 18/09/2022.
//

import Foundation
import CoreRepository

public protocol DataStore<T> {
    // swiftlint:disable type_name
    associatedtype T
    // swiftlint:enable type_name

    var ttl: TimeInterval { get }

    @discardableResult
    func save(_ value: T) async throws -> T
    @discardableResult
    func save(_ values: [T]) async throws -> [T]
    func delete(_ value: T) async throws
    func delete(_ value: [T]) async throws
    func erase() async throws
    func getList(options: DataStoreFetchOption) async throws -> ListDTO<T>

    func make(total: Int, page: Int, size: Int, previous: T?, next: T?) -> Paginated?
}

public protocol IdentifiableDataStore<T>: DataStore where T: Identifiable {
    func get(_ id: T.ID, options: DataStoreFetchOption?) async throws -> T
    func delete(_ id: T.ID, options: DataStoreFetchOption?) async throws

    func lastID() async throws -> T.ID
}
