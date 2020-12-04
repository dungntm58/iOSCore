//
//  APNSWorker.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 2/15/19.
//

import Combine
import UserNotifications

open class APNSWorker<ValueType> where ValueType: APNSEventProtocol {
    private let _subscriber: PassthroughSubject<ValueType, Error>

    public init() {
        self._subscriber = .init()
    }

    public var sharedPublisher: AnyPublisher<ValueType, Error> {
        _subscriber.eraseToAnyPublisher()
    }

    public func subscribe(_ data: ValueType) {
        self._subscriber.send(data)
    }
}
