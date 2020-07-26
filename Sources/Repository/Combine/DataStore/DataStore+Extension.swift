//
//  DataStore+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import Combine

extension DataStore {
    @inlinable
    public var ttl: TimeInterval { 0 }

    @inlinable
    public func saveAsync(_ value: T) -> AnyPublisher<T, Error> {
        Deferred {
            Future {
                promise in
                do {
                    try self.saveSync(value)
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
    public func saveAsync(_ values: [T]) -> AnyPublisher<[T], Error> {
        Deferred {
            Future {
                promise in
                do {
                    try self.saveSync(values)
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
    public func deleteAsync(_ value: T) -> AnyPublisher<Void, Error> {
        Deferred {
            Future {
                promise in
                do {
                    try self.deleteSync(value)
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
    public func getListAsync(options: DataStoreFetchOption) -> AnyPublisher<ListDTO<T>, Error> {
        Deferred {
            Future {
                promise in
                do {
                    let results = try self.getList(options: options)
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
        Deferred {
            Future {
                promise in
                do {
                    try self.eraseSync()
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
    public func deleteSync(_ id: T.ID, options: DataStoreFetchOption?) throws {
        guard let value = try? getSync(id, options: options) else {
            return
        }
        try deleteSync(value)
    }

    @inlinable
    public func getAsync(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<T, Error> {
        Deferred {
            Future {
                promise in
                do {
                    let value = try self.getSync(id, options: options)
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
    public func deleteAsync(_ id: T.ID, options: DataStoreFetchOption?) -> AnyPublisher<Void, Error> {
        Deferred {
            Future {
                promise in
                do {
                    try self.deleteSync(id, options: options)
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
