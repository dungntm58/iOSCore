//
//  DataStore+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

extension DataStore {
    @inlinable
    public var ttl: TimeInterval { 0 }

    @inlinable
    public func saveAsync(_ value: T) -> Observable<T> {
        .deferred {
            let value = try self.saveSync(value)
            #if !RELEASE && !PRODUCTION
            Swift.print("Save \(value) of type \(T.self) successfully!!!")
            #endif
            return .just(value)
        }
    }

    public func saveAsync(_ values: [T]) -> Observable<[T]> {
        .deferred {
            let values = try self.saveSync(values)
            #if !RELEASE && !PRODUCTION
            Swift.print("Save \(values.count) items of type \(T.self) successfully!!!")
            #endif
            return .just(values)
        }
    }

    @inlinable
    public func deleteAsync(_ value: T) -> Observable<Void> {
        .deferred {
            try self.deleteSync(value)
            #if !RELEASE && !PRODUCTION
            Swift.print("Delete \(value) of type \(T.self) successfully!!!")
            #endif
            return .just(())
        }
    }

    @inlinable
    public func deleteAsync(_ values: [T]) -> Observable<Void> {
        .deferred {
            try self.deleteSync(values)
            #if !RELEASE && !PRODUCTION
            Swift.print("Delete \(values.count) items of type \(T.self) successfully!!!")
            #endif
            return .just(())
        }
    }

    @inlinable
    public func getListAsync(options: DataStoreFetchOption) -> Observable<ListDTO<T>> {
        .deferred {
            let results = try self.getList(options: options)
            #if !RELEASE && !PRODUCTION
            Swift.print("Get \(results.data.count) items of type \(T.self) from cache successfully!!!")
            #endif
            return .just(results)
        }
    }

    @inlinable
    public func eraseAsync() -> Observable<Void> {
        .deferred {
            try self.eraseSync()
            #if !RELEASE && !PRODUCTION
            Swift.print("Erase all items of type \(T.self) successfully!!!")
            #endif
            return .just(())
        }
    }
}

extension IdentifiableDataStore {
    @inlinable
    public func deleteSync(_ id: T.ID, options: DataStoreFetchOption?) throws {
        guard let value = try? getSync(id, options: options) else { return }
        try deleteSync(value)
    }

    @inlinable
    public func getAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<T> {
        .deferred {
            let value = try self.getSync(id, options: options)
            #if !RELEASE && !PRODUCTION
            Swift.print("Get \(value) of type \(T.self) with id \(id) successfully!!!")
            #endif
            return .just(value)
        }
    }

    @inlinable
    public func deleteAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<Void> {
        .deferred {
            try self.deleteSync(id, options: options)
            #if !RELEASE && !PRODUCTION
            Swift.print("Delete item of type \(T.self) with id \(id) successfully!!!")
            #endif
            return .just(())
        }
    }
}
