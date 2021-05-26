//
//  ParentSceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Robert on 7/22/20.
//

import Foundation

@propertyWrapper
final public class ParentSceneDependencyReferenced<S> {

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: KeyPath<EnclosingSelf, ParentSceneDependencyReferenced<S>>
    ) -> S? where EnclosingSelf: UIViewController {
        let sceneDependencyReferenced = observed[keyPath: storageKeyPath]
        if S.self is AnyObject.Type,
           let dependency = sceneDependencyReferenced.dependency {
            return dependency
        }
        guard let scene = sceneDependencyReferenced.scene else {
            guard let scene = ReferenceManager.getAbstractScene(associatedWith: observed)?.parent else { return nil }
            sceneDependencyReferenced.scene = scene
            let dependency: S? = scene.getDependency(keyPath: sceneDependencyReferenced.keyPath)
            sceneDependencyReferenced.dependency = dependency
            return dependency
        }
        let dependency: S? = scene.getDependency(keyPath: sceneDependencyReferenced.keyPath)
        sceneDependencyReferenced.dependency = dependency
        return dependency
    }

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    private let keyPath: String?
    private weak var scene: Scenable?
    private var dependency: S?

    @available(*, unavailable, message: "@ParentSceneDependencyReferenced is only available on properties of UIViewController")
    public var wrappedValue: S? {
        fatalError()
    }
}
