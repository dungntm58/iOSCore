//
//  PaginationEpic.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 12/12/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreRepository

public protocol PaginationRequestOptions: FetchOptions {}

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

    public func apply(dispatcher: Observable<Action>, actionStream: Observable<Action>, stateStream: Observable<State>) -> Observable<Action> {
        let cancelAction = actionStream
            .of(type: .load)
            .compactMap { $0.payload as? PayloadListRequestable }
            .filter(\.cancelRunning)
        return dispatcher
            .of(type: .load)
            .map { $0.payload as? PayloadListRequestable }
            .filter { $0 == nil || !$0!.cancelRunning }
            .withUnretained(self)
            .flatMap { `self`, payload -> Observable<Payload.List.Response<Worker.T>> in
                return .concat(
                    .just(.init(isLoading: true)),
                    self.worker
                        .getList(options: self.toPaginationRequestOptions(from: payload))
                        .map { .init(from: $0, payload: payload) }
                )
            }
            .take(until: cancelAction)
            .map { $0.toAction() }
            .catch { .just($0.toAction()) }
    }

    open func toPaginationRequestOptions(from payload: PayloadListRequestable?) -> PaginationRequestOptions? {
        nil
    }
}
