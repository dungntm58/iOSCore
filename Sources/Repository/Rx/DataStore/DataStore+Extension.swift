//
//  DataStore+Extension.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension DataStore {
    var ttl: TimeInterval { 0 }

    func saveAsync(_ value: T) -> Observable<T> {
        .create {
            subscribe in
            do {
                let value = try self.saveSync(value)
                #if !RELEASE && !PRODUCTION
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
        .create {
            subscribe in
            do {
                let values = try self.saveSync(values)
                #if !RELEASE && !PRODUCTION
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

    func deleteAsync(_ value: T) -> Observable<Void> {
        .create {
            subscribe in
            do {
                try self.deleteSync(value)
                #if !RELEASE && !PRODUCTION
                Swift.print("Delete \(value) of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(())
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func getListAsync(options: DataStoreFetchOption) -> Observable<ListDTO<T>> {
        .create {
            subscribe in
            do {
                let results = try self.getList(options: options)
                #if !RELEASE && !PRODUCTION
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

    func eraseAsync() -> Observable<Void> {
        .create {
            subscribe in
            do {
                try self.eraseSync()
                #if !RELEASE && !PRODUCTION
                Swift.print("Erase all items of type \(T.self) successfully!!!")
                #endif
                subscribe.onNext(())
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }
}

public extension IdentifiableDataStore {
    func deleteSync(_ id: T.ID, options: DataStoreFetchOption?) throws {
        guard let value = try? getSync(id, options: options) else {
            return
        }
        try deleteSync(value)
    }

    func getAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<T> {
        .create {
            subscribe in
            do {
                let value = try self.getSync(id, options: options)
                #if !RELEASE && !PRODUCTION
                Swift.print("Get \(value) of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(value)
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }

    func deleteAsync(_ id: T.ID, options: DataStoreFetchOption?) -> Observable<Void> {
        .create {
            subscribe in
            do {
                try self.deleteSync(id, options: options)
                #if !RELEASE && !PRODUCTION
                Swift.print("Delete item of type \(T.self) with id \(id) successfully!!!")
                #endif
                subscribe.onNext(())
                subscribe.onCompleted()
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create()
        }
    }
}
