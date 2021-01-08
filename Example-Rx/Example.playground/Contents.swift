import CoreRedux
import RxSwift

struct ExAction: Actionable {
    enum `Type`: String {
        case a
        case b
        case c
        case d
        case e
    }
    
    let type: ExAction.`Type`
    let payload: Any
}

struct ExState: Stateable {
    let i: Int
}

class ExStore: Store<ExAction, ExState> {
    init() {
        super.init(reducer: ExReducer(), initialState: .init(i: 0), scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
        inject(
            {
                dispatcher, actionStream, _ in
                dispatcher
                    .of(type: .a)
                    .map { $0.payload as! Int }
                    .flatMap ({
                        i -> Observable<Action> in
                        Observable
                            .merge(
                                .just(ExAction(type: .d, payload: i + 1)),
                                Observable
                                    .just(ExAction(type: .b, payload: i + 1))
                                    .delay(.seconds(1), scheduler: self.scheduler)
                            )
                            .delay(.seconds(1), scheduler: self.scheduler)
                            .do(onNext: {
                                action in
                                print("Start with flatmap, next:", String(describing: action))
                            }, onCompleted: {
                                print("Done flatmap")
                            }, onDispose: {
                                print("Dispose flatmap")
                            })
                    })
                    .takeUntil(actionStream.of(type: .d))
                    .do(onNext: {
                        action in
                        print("Start with a, next:", String(describing: action))
                    }, onCompleted: {
                        print("Done a")
                    }, onDispose: {
                        print("Dispose a")
                    })
            },
            {
                dispatcher, actionStream, _ in
                dispatcher
                    .of(type: .b)
                    .map ({
                        _ in .init(type: .c, payload: 1)
                    })
            }
        )
    }
}

class ExReducer: Reducible {
    typealias Action = ExAction
    typealias State = ExState
    
    func reduce(action: Action, currentState: State) -> State {
        switch action.type {
        case .b:
            return State(i: currentState.i + (action.payload as! Int))
        case .c:
            return State(i: currentState.i + (action.payload as! Int))
        default:
            return currentState
        }
    }
}

let store = ExStore()
store.activate()

store.dispatch(type: .a, payload: 0)
