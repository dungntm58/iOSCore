//
//  Scene+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import CoreRedux

public protocol ConnectedSceneRef: SceneRef where Scene: Connectable {}
public protocol ConnectedSceneBindableRef: SceneBindableRef, ConnectedSceneRef {}

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