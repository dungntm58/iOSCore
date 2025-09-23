//
//  SceneViewMacro.swift
//  CoreMacrosPlugin
//
//  Implementation of @SceneView macro for UIKit ViewControllers and SwiftUI Views
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro that makes View Controllers and SwiftUI Views scene-aware with automatic association
public struct SceneViewMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return [
            """
            public var scene: CoreMacroProtocols.Scene? {
                get {
                    if let viewManager = findViewManager() {
                        return viewManager.scene
                    }
                    return nil
                }
            }

            private func findViewManager() -> CoreBase.ViewManager? {
                // First check if this view controller itself has a ViewManager
                if let viewManager = CoreBase.ViewManagerRegistry.shared.findViewManager(for: self) {
                    return viewManager
                }
                // Walk up the parent hierarchy to find a ViewManager
                var current: UIViewController? = self
                while let parent = current?.parent {
                    if let viewManager = CoreBase.ViewManagerRegistry.shared.findViewManager(for: parent) {
                        return viewManager
                    }
                    current = parent
                }
                // Check presenting view controller chain
                current = self.presentingViewController
                while let presenter = current {
                    if let viewManager = CoreBase.ViewManagerRegistry.shared.findViewManager(for: presenter) {
                        return viewManager
                    }
                    current = presenter.presentingViewController
                }
                return nil
            }
            """
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let conformance: DeclSyntax =
        """
        extension \(type.trimmed): CoreMacroProtocols.SceneReferencing {}
        """

        guard let extensionDecl = conformance.as(ExtensionDeclSyntax.self) else {
            return []
        }

        return [extensionDecl]
    }
}
