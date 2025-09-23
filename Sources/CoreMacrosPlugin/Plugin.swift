//
//  Plugin.swift
//  CoreMacrosPlugin
//
//  Main plugin entry point for Swift macros
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CoreMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        // Dependency injection macros
        SceneMacro.self,
        SceneDependencyMacro.self,
        SceneDependencyReferenceMacro.self,
        SceneViewMacro.self,
        // Async initialization macros
        AsyncInitMacro.self,
    ]
}