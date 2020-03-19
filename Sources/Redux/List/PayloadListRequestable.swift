//
//  PayloadListRequestable.swift
//  RxCoreRedux
//
//  Created by Robert on 8/10/19.
//

public protocol PayloadListRequestable {
    var page: Int { get }
    var count: Int { get }
    var isAutoRequestCounting: Bool { get }
    var cancelRunning: Bool { get }
}

public extension PayloadListRequestable {
    func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ListActionType {
        .init(type: .load, payload: self)
    }
}
