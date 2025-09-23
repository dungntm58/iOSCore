//
//  SceneDependencyProtocols.swift
//  CoreMacroProtocols
//
//  Scene dependency injection protocols and registry
//

import Foundation

// MARK: - Scene Dependency Protocols

/// Protocol for any type that can reference a scene
public protocol SceneReferencing {
    var scene: Scene? { get }
}

/// Access token for macro-generated code only
public struct MacroAccessToken {
    fileprivate init() {}
}

/// Internal scene association storage for dependencies
public class SceneAssociationRegistry {
    public static let shared = SceneAssociationRegistry()
    private var associations: [ObjectIdentifier: WeakSceneRef] = [:]
    private let queue = DispatchQueue(label: "scene.association.registry", attributes: .concurrent)

    private init() {}

    /// Secure association method that requires macro access token
    public func associate(_ dependency: AnyObject, with scene: Scene?, token: MacroAccessToken) {
        let id = ObjectIdentifier(dependency)
        queue.async(flags: .barrier) {
            if let scene = scene {
                self.associations[id] = WeakSceneRef(scene)
            } else {
                self.associations.removeValue(forKey: id)
            }
        }
    }

    public func scene(for dependency: AnyObject) -> Scene? {
        let id = ObjectIdentifier(dependency)
        return queue.sync {
            return associations[id]?.scene
        }
    }
}

/// Public access to macro token for generated code only
/// Note: This is intentionally hard to discover and use
public func __sceneDependencyMacroToken() -> MacroAccessToken {
    return MacroAccessToken()
}

private class WeakSceneRef {
    weak var scene: Scene?
    init(_ scene: Scene) { self.scene = scene }
}

/// Protocol for types that can be scene dependencies
public protocol SceneDependency: SceneReferencing, AnyObject {}

public extension SceneDependency {
    var scene: Scene? {
        SceneAssociationRegistry.shared.scene(for: self)
    }
}
