//
//  Scene.swift
//  RxCoreBase
//
//  Created by Robert on 8/15/19.
//

public protocol SceneBindable {
    func bind(to scene: Scenable)
}

public protocol SceneRef: class {
    associatedtype Scene: Scenable

    var scene: Scene? { set get }
}

public protocol SceneBindableRef: SceneBindable, SceneRef {}

public extension SceneBindable where Self: SceneRef {
    func bind(to scene: Scenable) {
        self.scene = scene as? Scene
    }
}
