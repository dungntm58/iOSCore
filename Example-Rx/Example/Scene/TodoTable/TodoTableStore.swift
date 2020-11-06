//
//  TodoTableStore.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux

class TodoTableStore: CoreRedux.Store<TodoReducer.Action, TodoReducer.State> {
    init() {
        super.init(reducer: TodoReducer(), initialState: .init())
        self <| TodoListEpic()
    }
}
