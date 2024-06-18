//
//  PaginationEpic.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 12/12/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import Combine
import CoreRedux
import CoreRepository

public protocol PaginationRequestOptions: FetchOptions {}

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

public protocol ListDataWorker<T> {
    // swiftlint:disable type_name
    associatedtype T
    // swiftlint:enable type_name

    func getList(options: PaginationRequestOptions?) -> AnyPublisher<ListDTO<T>, Error>
}

open class BaseListEpic<Action, State, Worker>: Epic where
    Action: Actionable,
    Action.ActionType: ListActionType,
    State: Stateable,
    Worker: ListDataWorker,
    Worker.T: Equatable {

    public let worker: Worker

    public init(worker: Worker) {
        self.worker = worker
    }

    public func apply(dispatcher: AnyPublisher<Action, Never>, actionStream: AnyPublisher<Action, Never>, stateStream: AnyPublisher<State, Never>) -> AnyPublisher<Action, Never> {
        dispatcher
            .of(type: .load)
            .map { $0.payload as? PayloadListRequestable }
            .flatMap { [weak self] payload -> AnyPublisher<Action, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let requestPublisher = self.worker
                    .getList(options: self.toPaginationRequestOptions(from: payload))
                    .map { Payload.List.Response<Worker.T>(from: $0, payload: payload) }
                    .eraseToAnyPublisher()
                let cancelRunningPublisher = actionStream
                    .of(type: .load)
                    .compactMap { $0.payload as? PayloadListRequestable }
                    .filter { $0.cancelRunning }
                return Just(Payload.List.Response<Worker.T>(isLoading: true))
                    .setFailureType(to: Error.self)
                    .append(requestPublisher)
                    .prefix(untilOutputFrom: cancelRunningPublisher)
                    .map { $0.toAction() }
                    .`catch` { Just($0.toAction()).eraseToAnyPublisher() }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    open func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        nil
    }
}
