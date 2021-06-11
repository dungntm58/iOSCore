//
//  Scene.swift
//  CoreBase
//
//  Created by Robert on 8/15/19.
//

@propertyWrapper
final public class SceneReferenced<S> {

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: KeyPath<EnclosingSelf, SceneReferenced<S>>
    ) -> S? where EnclosingSelf: UIViewController {
        let sceneReferenced = observed[keyPath: storageKeyPath]
        if let scene = sceneReferenced.scene as? S { return scene }
        let scene: S? = ReferenceManager.getScene(associatedWith: observed)
        sceneReferenced.scene = scene as? Scened
        return scene
    }

    public init() {}

    private weak var scene: Scened?

    @available(*, unavailable, message: "@SceneDependency is only available on properties of UIViewController")
    public var wrappedValue: S? {
        fatalError()
    }
}
