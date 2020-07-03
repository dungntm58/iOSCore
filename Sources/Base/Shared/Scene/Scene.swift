//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

open class Scene: Scenable {
    public let managedContext: ManagedSceneContext

    public init() {
        self.managedContext = .init()
    }

    public init(managedContext: ManagedSceneContext) {
        self.managedContext = managedContext
    }

    open func perform(with userInfo: Any?) {
        // No-op
    }

    open func prepare(for scene: Scenable) {
        // No-op
    }

    open func onDetach() {
        // No-op
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
