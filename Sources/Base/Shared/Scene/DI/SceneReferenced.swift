//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

import UIKit

@available(iOS, deprecated, message: "Use computed property `scene` instead")
@propertyWrapper
final public class SceneReferenced<S> {

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: KeyPath<EnclosingSelf, SceneReferenced<S>>
    ) -> S? where EnclosingSelf: SceneAssociated {
        let sceneReferenced = observed[keyPath: storageKeyPath]
        if let scene = sceneReferenced.scene as? S { return scene }
        sceneReferenced.scene = observed.scene
        return sceneReferenced.scene as? S
    }

    public init() {}

    private weak var scene: Scened?

    @available(*, unavailable, message: "@SceneDependency is only available on properties of UIViewController")
    public var wrappedValue: S? {
        fatalError()
    }
}
