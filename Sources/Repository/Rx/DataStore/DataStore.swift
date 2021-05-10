//
//  DataStore.swift
//  CoreRepository
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

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
    func eraseSync() throws
    func getList(options: DataStoreFetchOption) throws -> ListDTO<T>

    func make(total: Int, size: Int, previous: T?, next: T?) -> PaginationDTO

    func saveAsync(_ value: T) -> Observable<T>
    func saveAsync(_ values: [T]) -> Observable<[T]>
    func deleteAsync(_ value: T) -> Observable<Void>
    func eraseAsync() -> Observable<Void>
    func getListAsync(options: DataStoreFetchOption) -> Observable<ListDTO<T>>
}

public protocol IdentifiableDataStore: DataStore where T: Identifiable {
    func getSync(_ id: T.ID, options: DataStoreFetchOption?) throws -> T
    func deleteSync(_ id: T.ID, options: DataStoreFetchOption?) throws

    func getAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<T>
    func deleteAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<Void>

    func lastID() throws -> T.ID
}
