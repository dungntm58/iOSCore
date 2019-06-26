//
//  APNSWorker.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 2/15/19.
//

import RxSwift
import CoreCleanSwiftBase
import UserNotifications

open class APNSWorker<ValueType>: DataWorker where ValueType: APNSDataProtocol {
    private var _subscriber: AnyObserver<ValueType>?

    private(set) lazy public var sharedObservable: Observable<ValueType> = {
        return Observable<ValueType>.create {
            [weak self] subscriber in
            self?._subscriber = subscriber
            
            return Disposables.create()
        }.share()
    }()

    public func subscribe(_ data: ValueType) {
        self._subscriber?.onNext(data)
    }

    public func error(_ error: Error) {
        self._subscriber?.onError(error)
    }

    public func complete() {
        self._subscriber?.onCompleted()
        self._subscriber = nil
    }

    public func createSharedObservable() {
        sharedObservable = Observable<ValueType>.create {
            [weak self] subscriber in
            self?._subscriber = subscriber

            return Disposables.create()
        }.share()
    }
}
