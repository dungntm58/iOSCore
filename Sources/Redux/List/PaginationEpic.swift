//
//  PaginationEpic.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 12/12/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import Combine
import CoreRepository

public protocol PaginationRequestOptions: FetchOptions {}

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

public protocol ListDataWorker {
    associatedtype T

    func getList(options: PaginationRequestOptions?) -> AnyPublisher<ListDTO<T>, Error>
}

open class BaseListEpic<Action, State, Worker>: Epic where
    Action: Actionable,
    Action.ActionType: ListActionType,
    State: Statable,
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
            .flatMap ({
                payload -> AnyPublisher<Action, Never> in
                Future<Payload.List.Response<Worker.T>, Error> { $0(.success(.init(isLoading: true))) }
                    .append(
                        self.worker
                            .getList(options: self.toPaginationRequestOptions(from: payload))
                            .map { .init(from: $0, payload: payload) }
                            .eraseToAnyPublisher())
                    .prefix(untilOutputFrom: actionStream
                        .of(type: .load)
                        .compactMap { $0.payload as? PayloadListRequestable }
                        .filter { $0.cancelRunning })
                    .map { $0.toAction() }
                    .catch { Just($0.toAction()).eraseToAnyPublisher() }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    open func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        nil
    }
}
