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

        let mirror = Mirror(reflecting: self)
        for (_, value) in mirror.children {
            if let sceneRef = value as? SceneAssociated {
                sceneRef.associate(with: self)
            }
        }
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
