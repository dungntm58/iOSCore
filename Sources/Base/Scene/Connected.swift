//
//  Connected.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 6/8/19.
//

import RxSwift
import CoreCleanSwiftRedux

open class ConnectableScene<Store>: Scene, Connectable where Store: Storable {
    public let managedContext: ManagedSceneContext
    public let store: Store

    private(set) public lazy var disposeBag = DisposeBag()

    public init(store: Store) {
        self.managedContext = ManagedSceneContext()
        self.store = store
        self.lifeCycle
            .map {
                state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            }
            .distinctUntilChanged()
            .subscribe(
                onNext: {
                    [store] value in
                    value ? store.activate() : store.deactivate()
                }
            )
            .disposed(by: disposeBag)
    }

    open func perform() {}
    open func onDetach() {}
}

open class ConnectableViewableScene<Store>: ConnectableScene<Store>, Viewable where Store: Storable {
    public let viewManager: ViewManager

    public init(store: Store, viewController: UIViewController) {
        self.viewManager = ViewManager(viewController: viewController)
        super.init(store: store)
    }

    open override func onDetach() {
        viewManager.dismiss()
    }
}
