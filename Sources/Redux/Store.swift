//
//  Store.swift
//  CoreCleanSwiftRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift
import RxRelay

public protocol Dispatchable {
    associatedtype Action: Actionable

    func dispatch(type: Action.ActionType, payload: Any)
    func dispatch(_ action: Action...)
    func dispatch(_ actions: [Action])
}

public protocol Storable: class {
    associatedtype Reducer: Reducable
    typealias State = Reducer.State

    var currentState: State { get }
    var state: Observable<State> { get }
    var isActive: Observable<Bool> { get }

    func activate()
    func deactivate()
}

open class Store<Action, Reducer>: Storable, Dispatchable where Reducer: Reducable, Reducer.Action == Action {
    public typealias State = Reducer.State

    private let _disposeBag: DisposeBag
    private let _state: BehaviorRelay<State>
    private let _action: PublishRelay<Action>
    private let _dispatcher: PublishRelay<Action>
    private var _isActive: BehaviorRelay<Bool>
    private let _reducer: Reducer

    public var currentState: State {
        return _state.value
    }

    public var state: Observable<State> {
        return _state.asObservable()
    }

    public var isActive: Observable<Bool> {
        return _isActive.distinctUntilChanged()
    }

    public init(reducer: Reducer, initialState: State) {
        _disposeBag = DisposeBag()
        _state = BehaviorRelay(value: initialState)
        _isActive = BehaviorRelay(value: false)
        _action = PublishRelay()
        _dispatcher = PublishRelay()
        _reducer = reducer
    }

    public func activate() {
        _isActive.accept(true)
    }

    public func deactivate() {
        _isActive.accept(false)
    }

    public func dispatch(type: Action.ActionType, payload: Any) {
        dispatch(Action(type: type, payload: payload))
    }

    public func dispatch(_ action: Action...) {
        dispatch(action)
    }

    public func dispatch(_ actions: [Action]) {
        for act in actions {
            _dispatcher.accept(act)
        }
    }

    public func inject(_ epic: EpicFunction<Action, State>...) {
        self.inject(epic)
    }

    public func inject(_ epics: [EpicFunction<Action, State>]) {
        fork(from: _dispatcher.asObservable(), middleware: epics)
    }

    private func fork(from action: Observable<Action>, middleware epics: [EpicFunction<Action, State>]) {
        let dispatch = action
            .withLatestFrom(_isActive) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .share()

        dispatch
            .bind(to: _action)
            .disposed(by: _disposeBag)

        let state = dispatch
            .flatMap {
                [_action, _state] action -> Observable<Action> in
                return .merge(epics.map { $0(_action.asObservable(), _state.asObservable()) })
            }
            .do(onNext: {
                [weak self] action in
                self?.fork(from: .just(action), middleware: epics)
            })
            .withLatestFrom(_state) {
                [_reducer] action, state in
                _reducer.reduce(action: action, currentState: state)
            }

        state
            .bind(to: _state)
            .disposed(by: _disposeBag)
    }
}
