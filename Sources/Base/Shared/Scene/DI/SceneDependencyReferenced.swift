//
//  SceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import UIKit

public protocol SceneAssociated: AnyObject {
    func associate(with scene: Scened)
    var scene: Scened? { get }
}

class DependencyObservationCenter {
    private struct SceneDependencyObserver {
        weak var scene: Scened?
        weak var dependencyRef: SceneDependencyObservable?
    }

    static let `default` = DependencyObservationCenter()

    private var observers: [SceneDependencyObserver] = []

    func register(scene: Scened, dependencyRef: SceneDependencyObservable) {
        observers = observers.filter { $0.scene == nil || $0.dependencyRef == nil }
        observers.append(.init(scene: scene, dependencyRef: dependencyRef))
    }

    func notifyChanges(scene: Scened, keyPath: AnyKeyPath) {
        observers
            .filter { $0.scene === scene }
            .forEach { $0.dependencyRef?.updateChange(keyPath: keyPath) }
    }
}

public protocol SceneDependencyObservable: AnyObject {
    func updateChange(keyPath: AnyKeyPath)
}

@propertyWrapper
final public class SceneDependency<S> {

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
            (sceneDependency.dependency as? SceneAssociated)?.associate(with: observed)
            sceneDependency.isAssociated = true
            return sceneDependency.dependency
        }
        set {
            let sceneDependency = observed[keyPath: storageKeyPath]
            sceneDependency.dependency = newValue
            (newValue as? SceneAssociated)?.associate(with: observed)
            sceneDependency.isAssociated = true
            DependencyObservationCenter.default.notifyChanges(scene: observed, keyPath: wrappedKeyPath)
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
final public class SceneDependencyReferenced<S>: SceneDependencyObservable {

    public static subscript<EnclosingSelf>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
        storage storageKeyPath: KeyPath<EnclosingSelf, SceneDependencyReferenced<S>>
    ) -> S? where EnclosingSelf: SceneAssociated {
        let sceneDependencyReferenced = observed[keyPath: storageKeyPath]
        sceneDependencyReferenced.observed = observed
        if S.self is AnyObject.Type,
           let dependency = sceneDependencyReferenced.dependency ?? sceneDependencyReferenced.weakDependency as? S {
            return dependency
        }
        sceneDependencyReferenced.retrieveDependency()
        return sceneDependencyReferenced.dependency ?? sceneDependencyReferenced.weakDependency as? S
    }

    public init(keyPath: String? = nil) {
        self.keyPath = keyPath.map(KeyPathValue.string)
    }

    public init(keyPath: AnyKeyPath) {
        self.keyPath = .concrete(keyPath)
    }

    private let keyPath: KeyPathValue?
    private weak var scene: Scened? {
        didSet {
            guard let scene = scene else {
                return
            }
            DependencyObservationCenter.default.register(scene: scene, dependencyRef: self)
        }
    }
    private weak var observed: SceneAssociated?
    private var dependency: S?
    private weak var weakDependency: AnyObject?

    @available(*, unavailable, message: "@SceneDependencyReferenced is only available on properties of SceneAssociated")
    public var wrappedValue: S? {
        fatalError()
    }

    public func updateChange(keyPath: AnyKeyPath) {
        guard let kValue = self.keyPath else {
            return updateDependency(keyPath: keyPath)
        }
        switch kValue {
        case .string:
            retrieveDependency()
        case .concrete(let value):
            if value == keyPath {
                updateDependency(keyPath: keyPath)
            }
        }
    }

    private func updateDependency(keyPath: AnyKeyPath) {
        let dependency = scene?[keyPath: keyPath]
        guard dependency is S? else {
            return
        }
        if dependency as AnyObject === observed {
            self.weakDependency = dependency as AnyObject?
        } else {
            self.dependency = dependency as? S
        }
    }

    private func retrieveDependency() {
        if let scene = scene {
            let dependency: S? = scene.getDependency(keyPath: keyPath)
            if dependency as AnyObject === observed {
                self.weakDependency = dependency as AnyObject?
            } else {
                self.dependency = dependency
            }
            return
        }
        guard let scene = observed?.scene else { return }
        self.scene = scene
        let dependency: S? = scene.getDependency(keyPath: keyPath)
        if dependency as AnyObject === observed {
            self.weakDependency = dependency as AnyObject?
        } else {
            self.dependency = dependency
        }
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
#if !RELEASE && !PRODUCTION
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
                return dependencyChildren[0]
            }
            assertionFailure("Ambiguous reference to member of type \(Dependency.self)")
            return nil
#else
            return children.first { child -> Dependency? in
                if let viewManager = child.value as? Dependency {
                    return viewManager
                }
                let dependency = Mirror(reflecting: child.value)
                    .children
                    .first { $0.label == "dependency" }?
                    .value
                return dependency.flattened() as? Dependency
            }
#endif
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
