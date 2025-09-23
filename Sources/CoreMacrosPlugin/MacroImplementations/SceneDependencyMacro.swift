//
//  SceneDependencyMacro.swift
//  CoreMacrosPlugin
//
//  Implementation of @SceneDependency and @SceneDependencyReference macros
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import CoreMacroProtocols

/// Macro to mark types as Scene dependencies
/// Makes the type conform to SceneDependency protocol
public struct SceneDependencyMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Generate SceneDependency protocol conformance
        let conformance: DeclSyntax =
        """
        extension \(type.trimmed): CoreMacroProtocols.SceneDependency {}
        """

        guard let extensionDecl = conformance.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDecl]
    }

}
