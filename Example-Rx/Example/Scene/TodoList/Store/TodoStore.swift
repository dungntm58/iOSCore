//
//  Core-CleanSwift-ExampleInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/15/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import CoreRedux
import CoreList

class TodoStore: CoreRedux.Store<TodoReducer.Action, TodoReducer.State> {
    init() {
        super.init(reducer: TodoReducer(), initialState: .init())
        self
            <| TodoCreateEpic()
            <| {
                dispatcher, _, _ in
                dispatcher
                    .of(type: .logout)
                    .do(onNext: { _ in AppPreferences.instance.token = nil })
                    .map { _ in Action(type: .logoutSuccess, payload: 0) }
            }
    }
}
