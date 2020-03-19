//
//  Scene+Redux.swift
//  RxCoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import RxSwift
import RxCoreRedux

public protocol ConnectedSceneRef: SceneRef where Scene: Connectable {}
public protocol ConnectedSceneBindableRef: SceneBindableRef, ConnectedSceneRef, Activating {}

public extension Activating where Self: ConnectedSceneRef {
    func activate() {
        scene?.store.activate()
    }

    func deactivate() {
        scene?.store.deactivate()
    }
}

open class ConnectableScene<Store>: Scene, Connectable where Store: Storable {
    public let store: Store

    public init(store: Store, managedContext: ManagedSceneContext = .init()) {
        self.store = store
        super.init(managedContext: managedContext)
        config()
    }
}

open class ViewableScene: Scene, Viewable {
    public var viewManager: ViewManagable

    public init(managedContext: ManagedSceneContext = .init(), viewManager: ViewManagable) {
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
    }

    public init(managedContext: ManagedSceneContext = ManagedSceneContext(), viewController: UIViewController) {
        let viewManager = ViewManager(viewController: viewController)
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        viewManager.bind(scene: self)
    }

    open override func onDetach() {
        viewManager.dismiss(animated: true, completion: nil)
    }
}

open class ConnectableViewableScene<Store>: Scene, Connectable, Viewable where Store: Storable {
    public let store: Store
    public let viewManager: ViewManagable

    public init(managedContext: ManagedSceneContext = .init(), store: Store, viewManager: ViewManagable) {
        self.store = store
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        config()
    }

    public init(managedContext: ManagedSceneContext = .init(), store: Store, viewController: UIViewController) {
        self.store = store
        let viewManager = ViewManager(viewController: viewController)
        self.viewManager = viewManager
        super.init(managedContext: managedContext)
        viewManager.bind(scene: self)
        config()
    }

    open override func onDetach() {
        viewManager.dismiss(animated: true, completion: nil)
    }
}

extension Scenable where Self: Connectable {
    func config() {
        let lifeCycleDiposable = self.lifeCycle
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
            .subscribe(onNext: {
                [store] shouldActiveStore in
                shouldActiveStore ? store.activate() : store.deactivate()
            })
        _ = managedContext.insertDisposable(lifeCycleDiposable)
    }
}
