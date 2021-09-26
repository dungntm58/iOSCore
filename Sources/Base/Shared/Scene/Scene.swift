//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Foundation

open class Scene: Scened {
    public let managedContext: ManagedSceneContext
    public let id: String

    public init(managedContext: ManagedSceneContext = .init()) {
        self.managedContext = managedContext
        self.id = UUID().uuidString
    }

#if !RELEASE && !PRODUCTION
    deinit {
        print("Deinit", String(describing: Self.self))
    }
#endif

    open func perform(with userInfo: Any?) {
        // No-op
    }

    open func prepare(for scene: Scened) {
        // No-op
    }

    open func onDetach() {
        // No-op
    }
}
