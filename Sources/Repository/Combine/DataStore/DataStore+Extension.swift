//
//  DataStore+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import Foundation
import Combine
import CoreRepository

extension DataStore {
    @inlinable
    public var ttl: TimeInterval { 0 }

    @inlinable
    public func save(_ value: T) -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                do {
                    try await self.save(value)
#if !RELEASE && !PRODUCTION
                    Swift.print("Save \(value) of type \(T.self) successfully!!!")
#endif
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func save(_ values: [T]) -> AnyPublisher<[T], Error> {
        Future { promise in
            Task {
                do {
                    try await self.save(values)
#if !RELEASE && !PRODUCTION
                    Swift.print("Save \(values.count) items of type \(T.self) successfully!!!")
#endif
                    promise(.success(values))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ value: T) -> AnyPublisher<Void, Error> {
        Future { promise in
            Task {
                do {
                    try await self.delete(value)
#if !RELEASE && !PRODUCTION
                    Swift.print("Delete \(value) of type \(T.self) successfully!!!")
#endif
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ values: [T]) -> AnyPublisher<Void, Error> {
        Future { promise in
            Task {
                do {
                    try await self.delete(values)
#if !RELEASE && !PRODUCTION
                    Swift.print("Delete \(values.count) items of type \(T.self) successfully!!!")
#endif
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func getList(options: DataStoreFetchOption) -> AnyPublisher<ListDTO<T>, Error> {
        Future { promise in
            Task {
                do {
                    let results = try await self.getList(options: options)
#if !RELEASE && !PRODUCTION
                    Swift.print("Get \(results.data.count) items of type \(T.self) from cache successfully!!!")
#endif
                    promise(.success(results))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func eraseAsync() -> AnyPublisher<Void, Error> {
        Future { promise in
            Task {
                do {
                    try await self.erase()
#if !RELEASE && !PRODUCTION
                    Swift.print("Erase all items of type \(T.self) successfully!!!")
#endif
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension IdentifiableDataStore {
    @inlinable
    public func get(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                do {
                    let value = try await self.get(id, options: options)
#if !RELEASE && !PRODUCTION
                    Swift.print("Get \(value) of type \(T.self) with id \(id) successfully!!!")
#endif
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<Void, Error> {
        Future { promise in
            Task {
                do {
                    try await self.delete(id, options: options)
#if !RELEASE && !PRODUCTION
                    Swift.print("Delete item of type \(T.self) with id \(id) successfully!!!")
#endif
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
