//
//  APNSWorker.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 2/15/19.
//

import RxSwift
import RxRelay
import UserNotifications

open class APNSWorker<ValueType> where ValueType: APNSEventProtocol {
    private let _subscriber: PublishSubject<ValueType>

    public init() {
        self._subscriber = PublishSubject()
    }

    public var sharedObservable: Observable<ValueType> {
        _subscriber.asObservable()
    }

    public func subscribe(_ data: ValueType) {
        self._subscriber.onNext(data)
    }
}
