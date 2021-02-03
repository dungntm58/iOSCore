//
//  SceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import UIKit

public protocol SceneAssociated: class {
    func associate(with scene: Scenable)
}

extension SceneAssociated where Self: UIViewController {
    @inlinable
    public func associate(with scene: Scenable) {
        ReferenceManager.setScene(scene, associatedViewController: self)
    }
}

@propertyWrapper
final public class SceneDependency<S>: SceneAssociated where S: SceneAssociated {

    private weak var scene: Scenable?
    private var dependency: S?
    private var isSceneConfig = false

    public init(wrappedValue: S?) {
        self.dependency = wrappedValue
    }

    public func associate(with scene: Scenable) {
        guard let dependency = dependency else { return }
        if isSceneConfig { return }
        dependency.associate(with: scene)
        isSceneConfig = true
    }

    public var wrappedValue: S? {
        set {
            self.dependency = newValue
            guard let scene = scene, let dependency = newValue else { return }
            if isSceneConfig || self.dependency === dependency { return }
            dependency.associate(with: scene)
            isSceneConfig = true
        }
        get { dependency }
    }
}

@propertyWrapper
final public class SceneDependencyReferenced<S>: ViewControllerAssociated {

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath
    }

    private let keyPath: String?
    private weak var scene: Scenable?
    private weak var viewController: UIViewController?
    private var dependency: S?
    private var weakDependency: AnyWeak?

    public func associate(with viewController: UIViewController) {
        self.viewController = viewController
        self.scene = ReferenceManager.getAbstractScene(associatedWith: viewController)
    }

    public var wrappedValue: S? {
        if let dependency = dependency ?? weakDependency?.value as? S { return dependency }
        guard let scene = scene else {
            guard let viewController = viewController,
                let scene = ReferenceManager.getAbstractScene(associatedWith: viewController) else { return nil }
            self.scene = scene
            let dependency: S? = scene.getDependency(keyPath: keyPath)
            if dependency as? UIViewController === viewController {
                self.weakDependency = AnyWeak(value: viewController)
            } else {
                self.dependency = dependency
            }
            return dependency
        }
        let dependency: S? = scene.getDependency(keyPath: keyPath)
        if dependency as? UIViewController === viewController {
            self.weakDependency = AnyWeak(value: viewController)
        } else {
            self.dependency = dependency
        }
        return dependency
    }
}

extension Scenable {
    func getDependency<Dependency>(keyPath: String?) -> Dependency? {
        let children = Mirror(reflecting: self).children
        if keyPath == nil {
            let dependencyChildren = children.compactMap {
                child -> Dependency? in
                if let viewManager = child.value as? Dependency {
                    return viewManager
                }
                let dependency = Mirror(reflecting: child.value)
                    .children
                    .first { $0.label == "dependency" }?
                    .value
                return dependency.flattened() as? Dependency
            }
            if dependencyChildren.count == 1 {
                return dependencyChildren.first
            }
            return nil
        }
        if let dependency = children.first(where: { $0.label == keyPath })?.value as? Dependency {
            return dependency
        }
        guard let keyPath = keyPath, let dependencyWrapper = children.first(where: { $0.label == "_\(keyPath)" })?.value else {
            return nil
        }
        let dependency = Mirror(reflecting: dependencyWrapper)
                    .children
                    .first { $0.label == "dependency" }?
                    .value
        return dependency.flattened() as? Dependency
    }
}
