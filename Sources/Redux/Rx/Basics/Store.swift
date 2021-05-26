//
//  Store.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift
import RxRelay

open class Store<Action, State>: Storable, Dispatchable where Action: Actionable, State: Stateable {
    public typealias StoreScheduler = SchedulerType

    private lazy var _disposables = CompositeDisposable()
    private lazy var disposeBag = DisposeBag()
    private let _state: BehaviorRelay<State>
    private let _action: PublishRelay<Action>
    private let _derivedAction: PublishRelay<Action>
    private var _epics: [EpicFunction<Action, State>]

    private(set) public var isActive: Bool

    open var reducer: ReduceFunction<Action, State>

    open var scheduler: StoreScheduler

    public var currentState: State { _state.value }

    public var state: Observable<State> {
        _state.asObservable().distinctUntilChanged()
    }

    #if !RELEASE && !PRODUCTION
    deinit {
        print("Deinit", String(describing: Self.self))
    }
    #endif

    public init<Reducer>(
        reducer: Reducer,
        initialState: State,
        scheduler: StoreScheduler = SerialDispatchQueueScheduler(qos: .default)
    ) where Reducer: Reducible, Reducer.Action == Action, Reducer.State == State {
        self._state = .init(value: initialState)
        self._action = .init()
        self._derivedAction = .init()
        self.reducer = reducer.reduce
        self._epics = []
        self.scheduler = scheduler
        self.isActive = false
        run()
    }

    public init(reducer: @escaping ReduceFunction<Action, State>, initialState: State, scheduler: StoreScheduler = SerialDispatchQueueScheduler(qos: .default)) {
        self._state = .init(value: initialState)
        self._action = .init()
        self._derivedAction = .init()
        self.reducer = reducer
        self._epics = []
        self.scheduler = scheduler
        self.isActive = false
        run()
    }

    public func activate() {
        self.isActive = true
    }

    public func deactivate() {
        self.isActive = false
    }

    @inlinable
    public func dispatch(type: Action.ActionType, payload: Any?) {
        dispatch(Action(type: type, payload: payload))
    }

    @inlinable
    public func dispatch(_ action: Action...) {
        dispatch(action)
    }

    public func dispatch(_ actions: [Action]) {
        actions.forEach { _action.accept($0) }
    }

    @inlinable
    public func inject<E>(_ epic: E...) where E: Epic, E.Action == Action, E.State == State {
        self.inject(epic.map { $0.apply })
    }

    @inlinable
    public func inject(_ epic: EpicFunction<Action, State>...) {
        self.inject(epic)
    }

    public func inject(_ epics: [EpicFunction<Action, State>]) {
        self._epics += epics
    }

    private func run() {
        #if !RELEASE && !PRODUCTION
        let actionToState = _derivedAction
            .withLatestFrom(_state) { [reducer] action, state -> (Action, State) in
                let newState = reducer(action, state)
                Swift.print("Previous state:", String(describing: state))
                Swift.print("Action:", String(describing: action))
                Swift.print("Next state:", String(describing: newState))
                return (action, newState)
            }
            .map(\.1)
            .bind(to: _state)
        #else
        let actionToState = _derivedAction
            .withLatestFrom(_state) { [reducer] action, state -> State in
                reducer(action, state)
            }
            .bind(to: _state)
        #endif
        let actionToDerivedAction = _action.bind(to: _derivedAction)
        // Handle epics
        let actionToAction = _action
            .observe(on: scheduler)
            .withUnretained(self)
            .flatMap { `self`, action -> Observable<Action> in
                guard self.isActive, !self._epics.isEmpty else { return .empty() }
                return .merge(self._epics.map { $0(.just(action), self._derivedAction.asObservable(), self._state.asObservable()).observe(on: self.scheduler) })
            }
            .catch { _ in .empty() }
            .bind(to: _action)
        _ = _disposables.insert(actionToDerivedAction)
        _ = _disposables.insert(actionToAction)
        _ = _disposables.insert(actionToState)
        _disposables.disposed(by: disposeBag)
    }
}

@discardableResult
@inlinable
public func <|<S, E> (store: S, epic: E) -> S where E: Epic, S: Store<E.Action, E.State> {
    store.inject(epic)
    return store
}

@discardableResult
@inlinable
public func <|<S, Action, State> (store: S, epic: @escaping EpicFunction<Action, State>) -> S
    where Action: Actionable, State: Stateable, S: Store<Action, State> {
    store.inject(epic)
    return store
}
