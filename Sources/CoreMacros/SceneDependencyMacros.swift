//
//  SceneDependencyMacros.swift
//  CoreMacros
//
//  Macro definitions for Scene dependency injection
//

import Foundation
import CoreMacroProtocols

/// Macro for dependency types - makes the type conform to SceneDependency protocol
/// Apply this to types like Store, Repository, Service, etc. that will be injected as dependencies
@attached(extension, conformances: SceneDependency)
public macro SceneDependency() = #externalMacro(module: "CoreMacrosPlugin", type: "SceneDependencyMacro")

/// Macro for Views to reference Scene dependencies (replaces @SceneDependencyReferenced)
/// Can ONLY be used on types that conform to SceneReferencing protocol (typically with @SceneView macro)
/// Generates efficient property access without Mirror reflection
@attached(accessor)
public macro SceneDependencyReference(keyPath: String? = nil) = #externalMacro(module: "CoreMacrosPlugin", type: "SceneDependencyReferenceMacro")
