//
//  SceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import UIKit

public protocol SceneAssociated: AnyObject {
    func associate(with scene: Scened)
}

extension SceneAssociated where Self: UIViewController {
    @inlinable
    public func associate(with scene: Scened) {
        ReferenceManager.setScene(scene, associatedViewController: self)
    }
}

@propertyWrapper
final public class SceneDependency<S> where S: SceneAssociated {

    private var isAssociated = false
    private var dependency: S?

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, SceneDependency<S>>
    ) -> S? where EnclosingSelf: Scened {
        get {
            let sceneDependency = observed[keyPath: storageKeyPath]
            if sceneDependency.isAssociated {
                return sceneDependency.dependency
            }
            sceneDependency.dependency?.associate(with: observed)
            sceneDependency.isAssociated = true
            return sceneDependency.dependency
        }
        set {
            let sceneDependency = observed[keyPath: storageKeyPath]
            sceneDependency.dependency = newValue
            newValue?.associate(with: observed)
            sceneDependency.isAssociated = true
        }
    }

    public init(wrappedValue: S?) {
        self.dependency = wrappedValue
    }

    @available(*, unavailable, message: "@SceneDependency is only available on properties of classes")
    public var wrappedValue: S? {
        get { fatalError() }
        // swiftlint:disable unused_setter_value
        set { fatalError() }
        // swiftlint:enable unused_setter_value
    }
}

enum KeyPathValue {
    case string(_ value: String)
    case concrete(_ value: AnyKeyPath)
}

@propertyWrapper
final public class SceneDependencyReferenced<S> {

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: KeyPath<EnclosingSelf, SceneDependencyReferenced<S>>
    ) -> S? where EnclosingSelf: UIViewController {
        let sceneDependencyReferenced = observed[keyPath: storageKeyPath]
        if S.self is AnyObject.Type,
           let dependency = sceneDependencyReferenced.dependency ?? sceneDependencyReferenced.weakDependency?.value as? S {
            return dependency
        }
        guard let scene = sceneDependencyReferenced.scene else {
            guard let scene = ReferenceManager.getAbstractScene(associatedWith: observed) else { return nil }
            sceneDependencyReferenced.scene = scene
            let dependency: S? = scene.getDependency(keyPath: sceneDependencyReferenced.keyPath)
            if dependency as? UIViewController === observed {
                sceneDependencyReferenced.weakDependency = AnyWeak(value: observed)
            } else {
                sceneDependencyReferenced.dependency = dependency
            }
            return dependency
        }
        let dependency: S? = scene.getDependency(keyPath: sceneDependencyReferenced.keyPath)
        if dependency as? UIViewController === observed {
            sceneDependencyReferenced.weakDependency = AnyWeak(value: observed)
        } else {
            sceneDependencyReferenced.dependency = dependency
        }
        return dependency
    }

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath.map { KeyPathValue.string($0) }
    }

    public init(keyPath: AnyKeyPath) {
        self.keyPath = .concrete(keyPath)
    }

    private let keyPath: KeyPathValue?
    private weak var scene: Scened?
    private var dependency: S?
    private var weakDependency: AnyWeak?

    @available(*, unavailable, message: "@SceneDependencyReferenced is only available on properties of UIViewController")
    public var wrappedValue: S? {
        fatalError()
    }
}

extension Scened {
    func getDependency<Dependency>(keyPath: KeyPathValue?) -> Dependency? {
        switch keyPath {
        case .string(let keyPath):
            return getDependencyWithPropertyName(keyPath: keyPath)
        case .concrete(let keyPath):
            return self[keyPath: keyPath] as? Dependency
        case .none:
            return getDependencyWithPropertyName(keyPath: nil)
        }
    }

    private func getDependencyWithPropertyName<Dependency>(keyPath: String?) -> Dependency? {
        let children = Mirror(reflecting: self).children
        if keyPath == nil {
            let dependencyChildren = children.compactMap { child -> Dependency? in
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
            assertionFailure("Ambiguous reference to member of type \(Dependency.self)")
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
