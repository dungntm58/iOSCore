//
//  PaginationReducer.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 4/4/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import RxSwift
import DifferenceKit
import CoreCleanSwiftRedux
import CoreCleanSwiftBase

open class BaseListReducer<T, Action>: Reducable where Action: Actionable, Action.ActionType: ListActionType, T: Equatable {
    public typealias State = Payload.List.Response<T>

    public init() {}

    open func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .updateListState:
            if let newState = action.payload as? State {
                return merge(currentState: currentState, newState: newState)
            }
        default:
            break
        }
        return currentState
    }

    open func merge(currentState: State, newState: State) -> State {
        if newState.isLoading {
            return .init(
                data: currentState.data,
                pagination: currentState.pagination,
                currentPage: currentState.currentPage,
                count: currentState.count,
                hasNext: currentState.hasNext,
                hasPrevious: currentState.hasPrevious,
                isLoading: newState.isLoading
            )
        }
        return
            .init(
                data: currentState.data + newState.data,
                pagination: newState.pagination,
                currentPage: newState.currentPage,
                count: newState.count,
                hasNext: newState.hasNext,
                hasPrevious: newState.hasPrevious
            )
    }
}

public protocol ListSelectable {
    func toList<T>() -> Payload.List.Response<T>
}
