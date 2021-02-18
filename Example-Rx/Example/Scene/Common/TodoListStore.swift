//
//  TodoTableStore.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux
import RxSwift

protocol TodoListViewModelProtocol {
    var todosObservable: Observable<Payload.List.Response<TodoEntity>> { get }
    var currentPage: Int { get }
    
    func load()
    func load(page: Int)
    func selectTodo(at index: Int)
}

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

extension TodoListStore: TodoListViewModelProtocol {
    var todosObservable: Observable<Payload.List.Response<TodoEntity>> {
        state.filter { $0.error == nil }
            .map(\.list)
            .distinctUntilChanged()
    }
    
    var currentPage: Int {
        currentState.list.currentPage
    }
    
    func load() {
        dispatch(type: .load, payload: 0)
    }
    
    func load(page: Int) {
        dispatch(type: .load, payload: Payload.List.Request(page: 1, cancelRunning: false))
    }
    
    func selectTodo(at index: Int) {
        dispatch(type: .selectTodo, payload: index)
    }
}
