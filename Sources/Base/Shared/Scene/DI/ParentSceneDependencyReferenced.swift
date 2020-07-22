//
//  ParentSceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Robert on 7/22/20.
//

import Foundation

@propertyWrapper
final public class ParentSceneDependencyReferenced<S>: ViewControllerAssociated where S: SceneAssociated {

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    private let keyPath: String?
    private weak var scene: Scenable?
    private weak var viewController: UIViewController?
    private var dependency: S?

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
        self.scene = ReferenceManager.getAbstractScene(associatedWith: viewController)?.parent
    }

    public var wrappedValue: S? {
        if let dependency = dependency { return dependency }
        guard let scene = scene else {
            guard let viewController = viewController,
                let scene = ReferenceManager.getAbstractScene(associatedWith: viewController)?.parent else { return nil }
            self.scene = scene
            self.dependency = scene.getDependency(keyPath: keyPath)
            return dependency
        }
        self.dependency = scene.getDependency(keyPath: keyPath)
        return dependency
    }
}
