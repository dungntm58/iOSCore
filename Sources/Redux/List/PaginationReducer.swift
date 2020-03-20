//
//  PaginationReducer.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 4/4/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

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
                pageSize: currentState.pageSize,
                hasNext: currentState.hasNext,
                hasPrevious: currentState.hasPrevious,
                isLoading: newState.isLoading
            )
        }
        return .init(
            data: newState.data,
            pagination: newState.pagination,
            currentPage: newState.currentPage,
            pageSize: newState.pageSize,
            hasNext: newState.hasNext,
            hasPrevious: newState.hasPrevious
        )
    }
}
