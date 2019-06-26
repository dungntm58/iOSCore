//
//  DataStore.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

public protocol DataStore {
    associatedtype T

    var ttl: TimeInterval { get }

    @discardableResult
    func saveSync(_ value: T) throws -> T
    @discardableResult
    func saveSync(_ values: [T]) throws -> [T]
    @discardableResult
    func deleteSync(_ value: T) throws -> Bool
    @discardableResult
    func eraseSync() throws -> Bool
    func getList(options: DataStoreFetchOption) throws -> ListResponse<T>

    func make(total: Int, size: Int, before: T?, after: T?) -> PaginationResponse

    func saveAsync(_ value: T) -> Observable<T>
    func saveAsync(_ values: [T]) -> Observable<[T]>
    func deleteAsync(_ value: T) -> Observable<Bool>
    func eraseAsync() -> Observable<Bool>
    func getListAsync(options: DataStoreFetchOption) -> Observable<ListResponse<T>>
}

public extension DataStore {
    var ttl: TimeInterval {
        get {
            return 0
        }
    }

    func saveAsync(_ value: T) -> Observable<T> {
        return .create {
            subscribe in

            do {
                try self.saveSync(value)
                #if DEBUG
                Swift.print("Save \(value) of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(value)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }

    func saveAsync(_ values: [T]) -> Observable<[T]> {
        return .create {
            subscribe in

            do {
                try self.saveSync(values)
                #if DEBUG
                Swift.print("Save \(values.count) items of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(values)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }

    func deleteAsync(_ value: T) -> Observable<Bool> {
        return .create {
            subscribe in

            do {
                let r = try self.deleteSync(value)
                #if DEBUG
                Swift.print("Delete \(value) of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }

    func getListAsync(options: DataStoreFetchOption) -> Observable<ListResponse<T>> {
        return .create {
            subscribe in

            do {
                let results = try self.getList(options: options)
                #if DEBUG
                Swift.print("Get \(results.data.count) items of type \(T.self) from cache successfully!!!")
                #endif
                subscribe.onNext(results)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }

    func eraseAsync() -> Observable<Bool> {
        return .create {
            subscribe in

            do {
                let r = try self.eraseSync()
                #if DEBUG
                Swift.print("Erase all items of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }
}

public protocol IdentifiableDataStore: DataStore where T: Identifiable {
    func getSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> T
    func deleteSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> Bool

    func getAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<T>
    func deleteAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<Bool>

    func lastID() throws -> T.IDType
}

public extension IdentifiableDataStore {
    func deleteSync(_ id: T.IDType, options: DataStoreFetchOption?) throws -> Bool {
        guard let value = try? getSync(id, options: options) else {
            return false
        }
        return try deleteSync(value)
    }

    func getAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<T> {
        return .create {
            subscribe in

            do {
                let value = try self.getSync(id, options: options)
                #if DEBUG
                Swift.print("Get \(value) of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(value)
                subscribe.onCompleted()
            }
            catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }

    func deleteAsync(_ id: T.IDType, options: DataStoreFetchOption?) -> Observable<Bool> {
        return .create {
            subscribe in

            do {
                let r = try self.deleteSync(id, options: options)
                #if DEBUG
                Swift.print("Delete item of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(r)
                subscribe.onCompleted()
            }
            catch {
                subscribe.onError(error)
            }

            return Disposables.create()
        }
    }
}

public enum DataStoreError: Error {
    case invalidParam(_ param: String)
    case notFound
    case saveFailure
    case updateFailure
    case lookForIDFailure
    case unknown

    public var localizedDescription: String {
        switch self {
        case .invalidParam(let param):
            return "Invalid params \(param)"
        case .notFound:
            return "Value not found"
        case .saveFailure:
            return "Failed to save"
        case .updateFailure:
            return "Failed to update"
        case .lookForIDFailure:
            return "Failed to find id"
        case .unknown:
            return "Unknown error"
        }
    }
}
