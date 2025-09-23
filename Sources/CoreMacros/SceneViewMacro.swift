//
//  SceneViewMacro.swift
//  CoreMacros
//
//  Macro definition for @SceneView
//

import Foundation
import CoreMacroProtocols

/// Macro for View Controllers and SwiftUI Views to automatically get scene reference
/// Provides clean scene access for both UIKit and SwiftUI in headed scenes
@attached(member, names: named(scene), named(discoverScene), named(findViewManager))
@attached(extension, conformances: SceneReferencing)
public macro SceneView() = #externalMacro(module: "CoreMacrosPlugin", type: "SceneViewMacro")
