//
//  SceneDependencyReferenceMacro.swift
//  CoreMacrosPlugin
//
//  Implementation of @SceneDependencyReference macro for views to access scene dependencies
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro for Views to reference Scene dependencies (replaces @SceneDependencyReferenced)
/// Can only be used on types that conform to SceneReferencing protocol
public struct SceneDependencyReferenceMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = binding.typeAnnotation?.type else {
            throw MacroError.invalidUsage("@SceneDependencyReference can only be applied to variable declarations")
        }

        // Get the containing type to validate SceneReferencing conformance
        // Use a more flexible approach to find the containing type
        var containingType: DeclGroupSyntax?

        // Try different approaches to find the containing declaration
        if let memberDecl = declaration.parent?.parent?.asProtocol(DeclGroupSyntax.self) {
            containingType = memberDecl
        } else if let memberBlockItem = declaration.parent?.as(MemberBlockItemSyntax.self),
                  let memberBlock = memberBlockItem.parent?.as(MemberBlockSyntax.self),
                  let declGroup = memberBlock.parent?.asProtocol(DeclGroupSyntax.self) {
            containingType = declGroup
        }

        // If we still can't find the containing type, be more permissive
        // This allows the macro to work even if our syntax tree navigation is incomplete
        if let containingType = containingType {
            // Check if the containing type has @SceneView macro or explicit SceneReferencing conformance
            let hasSceneViewMacro = hasSceneViewAttribute(in: containingType)
            let hasSceneReferencingConformance = hasExplicitSceneReferencingConformance(in: containingType)

            if !hasSceneViewMacro && !hasSceneReferencingConformance {
                throw MacroError.invalidUsage("@SceneDependencyReference can only be used on types that conform to SceneReferencing protocol. Add @SceneView macro or explicit SceneReferencing conformance.")
            }
        }
        // If we can't find the containing type, proceed anyway and let the compiler catch any issues

        let propertyName = identifier.text
        let keyPath = extractKeyPath(from: node) ?? propertyName

        // Extract the non-optional type for dependency resolution
        let nonOptionalType = MacroUtilities.unwrapOptionalType(type)

        return [
            """
            get async {
                guard let scene = scene else {
                    return nil
                }
                return await scene.resolveDependency(for: "\(raw: keyPath)", type: \(nonOptionalType).self)
            }
            """
        ]
    }

    private static func extractKeyPath(from node: AttributeSyntax) -> String? {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }

        for argument in arguments {
            if argument.label?.text == "keyPath",
               let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                return stringLiteral.segments.description.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
        }
        return nil
    }

    private static func hasSceneViewAttribute(in declaration: DeclGroupSyntax) -> Bool {
        // Check if the type has @SceneView attribute
        let checkAttributes: (AttributeListSyntax) -> Bool = { attributes in
            return attributes.contains { attribute in
                if case .attribute(let attr) = attribute {
                    // Check both simple identifiers and qualified identifiers
                    if let identifier = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
                        return identifier == "SceneView"
                    }
                    // Also check for qualified names (e.g., CoreMacros.SceneView)
                    if let memberType = attr.attributeName.as(MemberTypeSyntax.self),
                       memberType.name.text == "SceneView" {
                        return true
                    }
                }
                return false
            }
        }

        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return checkAttributes(classDecl.attributes)
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            return checkAttributes(structDecl.attributes)
        }
        return false
    }

    private static func hasExplicitSceneReferencingConformance(in declaration: DeclGroupSyntax) -> Bool {
        // Check if the type explicitly conforms to SceneReferencing
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl.inheritanceClause?.inheritedTypes.contains { inheritedType in
                if let identifier = inheritedType.type.as(IdentifierTypeSyntax.self)?.name.text {
                    return identifier == "SceneReferencing"
                }
                return false
            } ?? false
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            return structDecl.inheritanceClause?.inheritedTypes.contains { inheritedType in
                if let identifier = inheritedType.type.as(IdentifierTypeSyntax.self)?.name.text {
                    return identifier == "SceneReferencing"
                }
                return false
            } ?? false
        }
        return false
    }
}

enum MacroError: Error, CustomStringConvertible {
    case invalidUsage(String)

    var description: String {
        switch self {
        case .invalidUsage(let message):
            return "Invalid macro usage: \(message)"
        }
    }
}