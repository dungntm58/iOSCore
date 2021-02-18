//
//  Core-CleanSwift-ExampleInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/15/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import CoreRedux
import CoreList
import RxSwift

protocol TodoViewModelProtocol {
    var isLogoutObservable: Observable<Bool> { get }
    var errorObservale: Observable<Error> { get }
    var selectedTodoObservable: Observable<TodoEntity> { get }
    var selectedTodo: TodoEntity? { get }
    
    func createNewTodo(_ todo: String?)
    func logout()
}

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

extension TodoStore: TodoViewModelProtocol {
    var isLogoutObservable: Observable<Bool> {
        state.filter { $0.error == nil }
            .map(\.isLogout)
            .filter { $0 }
    }
    
    var errorObservale: Observable<Error> {
        state.filter { !$0.isLogout }
            .compactMap(\.error)
    }
    
    var selectedTodoObservable: Observable<TodoEntity> {
        state.filter { $0.error == nil && !$0.isLogout }
            .compactMap(\.selectedTodo)
    }
    
    var selectedTodo: TodoEntity? {
        currentState.selectedTodo
    }
    
    func createNewTodo(_ todo: String?) {
        dispatch(type: .createTodo, payload: todo)
    }
    
    func logout() {
        dispatch(type: .logout)
    }
}
