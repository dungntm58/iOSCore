//
//  PaginationEpic.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 12/12/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import RxSwift
import RxCoreRepository

public protocol PaginationRequestOptions: FetchOptions {}

/* Some convenience methods to get list of objects
 * Catch event from any repository
 * Not constraint to any lower-level class
 */

public protocol ListDataWorker {
    associatedtype T

    func getList(options: PaginationRequestOptions?) -> Observable<ListDTO<T>>
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

    public func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        dispatcher
            .of(type: .load)
            .map { $0.payload as? PayloadListRequestable }
            .flatMap {
                [weak self] payload -> Observable<Payload.List.Response<Worker.T>> in
                guard let `self` = self else { return .empty() }
                return .concat(
                    .just(.init(isLoading: true)),
                    self.worker
                        .getList(options: self.toPaginationRequestOptions(from: payload))
                        .map { .init(from: $0, payload: payload) }
                )
            }
            .takeUntil(
                actionStream
                    .of(type: .load)
                    .compactMap { $0.payload as? PayloadListRequestable }
                    .filter { $0.cancelRunning }
            )
            .map { $0.toAction() }
            .catchError { .just($0.toAction()) }
    }

    open func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        nil
    }
}
