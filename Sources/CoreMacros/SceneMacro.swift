//
//  SceneMacro.swift
//  CoreMacros
//
//  Macro definition for @Scene
//

import Foundation
import CoreMacroProtocols

/// Macro for Scene classes - automatically makes the class conform to Scene protocol
/// and provides dependency resolution capabilities. Auto-detects properties that could be
/// scene dependencies and generates storage/accessor logic via member generation. Also makes
/// dependency types conform to SceneDependency protocol and generates HasViewManagable conformance.
@attached(member, names: arbitrary)
@attached(extension, conformances: Scene, HasViewManagable)
public macro Scene() = #externalMacro(module: "CoreMacrosPlugin", type: "SceneMacro")
