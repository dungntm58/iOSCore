//
//  DataStore.swift
//  CoreRepository
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Foundation
import Combine
import FoundationExtInternal
import CoreRepository

public protocol DataStore {
    // swiftlint:disable type_name
    associatedtype T
    // swiftlint:enable type_name

    var ttl: TimeInterval { get }

    @discardableResult
    func saveSync(_ value: T) throws -> T
    @discardableResult
    func saveSync(_ values: [T]) throws -> [T]
    func deleteSync(_ value: T) throws
    func deleteSync(_ value: [T]) throws
    func eraseSync() throws
    func getList(options: DataStoreFetchOption) throws -> ListDTO<T>

    func make(total: Int, page: Int, size: Int, previous: T?, next: T?) -> Paginated?

    func saveAsync(_ value: T) -> AnyPublisher<T, Error>
    func saveAsync(_ values: [T]) -> AnyPublisher<[T], Error>
    func deleteAsync(_ value: T) -> AnyPublisher<Void, Error>
    func deleteAsync(_ value: [T]) -> AnyPublisher<Void, Error>
    func eraseAsync() -> AnyPublisher<Void, Error>
    func getListAsync(options: DataStoreFetchOption) -> AnyPublisher<ListDTO<T>, Error>
}

public protocol IdentifiableDataStore: DataStore where T: Identifiable {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T
    func deleteSync(_ id: T.ID, options: DataStoreFetchOption?) throws

    func getAsync(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<T, Error>
    func deleteAsync(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<Void, Error>

    func lastID() throws -> T.ID
}
