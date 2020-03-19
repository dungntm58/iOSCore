//
//  Scene.swift
//  RxCoreBase
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

    open func perform() {
        // No-op
    }

    open func prepare(for scene: Scenable) {
        // No-op
    }

    open func onDetach() {
        // No-op
    }
}
