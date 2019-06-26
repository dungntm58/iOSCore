//
//  PaginationEpic.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/12/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreCleanSwiftRedux
import CoreCleanSwiftBase

open class BaseListEpic<Action, State, Worker>: Epic where Action: Actionable, Action.ActionType: ListActionType, State: Statable, Worker: ListDataWorker {
    public let worker: Worker

    public init(worker: Worker) {
        self.worker = worker
    }

    public func apply(action: Observable<Action>, state: Observable<State>) -> Observable<Action> {
        return action
            .of(type: .load)
            .map { $0.payload as? PayloadListRequestable }
            .takeUntil(
                action
                    .of(type: .load)
                    .compactMap { $0.payload as? PayloadListRequestable }
                    .filter { $0.cancelRunning }
            )
            .flatMap {
                [weak self] payload -> Observable<Payload.List.Response<Worker.T>> in
                guard let `self` = self else { return .empty() }
                return .concat(
                    .just(.init(isLoading: true)),
                    self.worker
                        .getList(options: self.toPaginationRequest(from: payload))
                        .map { .init(from: $0, payload: payload) }
                )
            }
            .map { $0.toAction() }
            .catchError { .just(ErrorState(error: $0).toAction()) }
    }

    open func toPaginationRequest(from payload: PayloadListRequestable?) -> PaginationRequest? {
        return nil
    }
}
