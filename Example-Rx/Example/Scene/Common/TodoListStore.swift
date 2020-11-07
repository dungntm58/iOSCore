//
//  TodoTableStore.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux

class TodoListStore: CoreRedux.Store<TodoListReducer.Action, TodoListReducer.State> {
    init() {
        super.init(reducer: TodoListReducer(), initialState: .init())
        self
            <| TodoListEpic()
            <| {
                dispatch, action, _ in
                dispatch
                    .of(type: .addNewTodo)
                    .compactMap { $0.payload as? TodoEntity }
                    .map { Payload.List.Response(data: [$0]) }
                    .map { $0.toAction() }
            }
    }
}
