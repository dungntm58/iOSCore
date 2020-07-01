//
//  Store.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 5/15/19.
//

import Combine

open class Store<Action, State, StoreScheduler>: Storable, Dispatchable where Action: Actionable, State: Stateable, StoreScheduler: Scheduler {
    private let _state: CurrentValueSubject<State, Never>
    private let _action: PassthroughSubject<Action, Never>
    private let _derivedAction: PassthroughSubject<Action, Never>
    private var _epics: [EpicFunction<Action, State>]

    private lazy var cancellables: Set<AnyCancellable> = .init()

    private(set) public var isActive: Bool

    open var reducer: ReduceFunction<Action, State>

    open var scheduler: StoreScheduler
    open var schedulerOptions: StoreScheduler.SchedulerOptions?

    public var currentState: State { _state.value }

    public var state: AnyPublisher<State, Never> {
        _state.removeDuplicates().eraseToAnyPublisher()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    public init<Reducer>(reducer: Reducer, initialState: State, scheduler: StoreScheduler, schedulerOptions: StoreScheduler.SchedulerOptions? = nil) where Reducer: Reducable, Reducer.Action == Action, Reducer.State == State {
        self._state = .init(initialState)
        self._action = .init()
        self._derivedAction = .init()
        self.reducer = reducer.reduce
        self._epics = []
        self.scheduler = scheduler
        self.schedulerOptions = schedulerOptions
        self.isActive = false
        run()
    }

    public init(reducer: @escaping ReduceFunction<Action, State>, initialState: State, scheduler: StoreScheduler, schedulerOptions: StoreScheduler.SchedulerOptions? = nil) {
        self._state = .init(initialState)
        self._action = .init()
        self._derivedAction = .init()
        self.reducer = reducer
        self._epics = []
        self.scheduler = scheduler
        self.schedulerOptions = schedulerOptions
        self.isActive = false
        run()
    }

    public func activate() {
        self.isActive = true
    }

    public func deactivate() {
        self.isActive = false
    }

    public func dispatch(type: Action.ActionType, payload: Any) {
        dispatch(Action(type: type, payload: payload))
    }

    public func dispatch(_ action: Action...) {
        dispatch(action)
    }

    public func dispatch(_ actions: [Action]) {
        actions.forEach(_action.send)
    }

    public func inject<E>(_ epic: E...) where E: Epic, E.Action == Action, E.State == State {
        self.inject(epic.map { $0.apply })
    }

    public func inject(_ epic: EpicFunction<Action, State>...) {
        self.inject(epic)
    }

    public func inject(_ epics: [EpicFunction<Action, State>]) {
        self._epics += epics
    }

    private func run() {
        _derivedAction
            .combineLatest(_state, {
                [reducer] action, state -> (Action, State) in
                let newState = reducer(action, state)
                #if !RELEASE && !PRODUCTION
                Swift.print("Previous state:", String(describing: state))
                Swift.print("Action:", String(describing: action))
                Swift.print("Next state:", String(describing: newState))
                #endif
                return (action, newState)
            })
            .map(\.1)
            .sink(receiveValue: _state.send)
            .store(in: &cancellables)
        _action.sink(receiveValue: _derivedAction.send).store(in: &cancellables)
        // Handle epics
        _action
            .receive(on: scheduler, options: schedulerOptions)
            .flatMap ({
                [weak self] action -> AnyPublisher<Action, Never> in
                guard let `self` = self, self.isActive, !self._epics.isEmpty else {
                    return Empty().eraseToAnyPublisher()
                }
                let dispatchPublisher = Just(action).eraseToAnyPublisher()
                let derivedActionPublisher = self._derivedAction.eraseToAnyPublisher()
                let statePublisher = self._state.eraseToAnyPublisher()
                return Publishers.MergeMany(
                    self._epics
                        .map ({
                            $0(dispatchPublisher, derivedActionPublisher, statePublisher)
                                .receive(on: self.scheduler, options: self.schedulerOptions)
                        })
                ).eraseToAnyPublisher()
            })
            .sink(receiveValue: _action.send)
            .store(in: &cancellables)
    }
}

@discardableResult
public func <|<S, E, StoreScheduler> (store: S, epic: E) -> S where E: Epic, S: Store<E.Action, E.State, StoreScheduler> {
    store.inject(epic)
    return store
}

@discardableResult
public func <|<S, Action, State, StoreScheduler> (store: S, epic: @escaping EpicFunction<Action, State>) -> S
    where Action: Actionable, State: Stateable, S: Store<Action, State, StoreScheduler> {
    store.inject(epic)
    return store
}
