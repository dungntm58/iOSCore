//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

open class Scene: Scenable {
    public let managedContext: ManagedSceneContext
    public let id: String

    public init(managedContext: ManagedSceneContext = .init()) {
        self.managedContext = managedContext
        self.id = UUID().uuidString

        Mirror(reflecting: self)
            .children
            .compactMap { $0.value as? SceneAssociated }
            .forEach { $0.associate(with: self) }
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
