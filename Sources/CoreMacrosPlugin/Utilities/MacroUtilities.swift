//
//  MacroUtilities.swift
//  CoreMacrosPlugin
//
//  Shared utilities for macro implementations
//

import SwiftSyntax

/// Utilities for working with Swift syntax in macros
enum MacroUtilities {

    /// Unwraps optional types (T? or Optional<T>) to get the underlying type T
    static func unwrapOptionalType(_ type: TypeSyntax) -> TypeSyntax {
        // If the type is Optional<T> or T?, unwrap it to get T
        if let optionalType = type.as(OptionalTypeSyntax.self) {
            return optionalType.wrappedType
        }
        if let identifierType = type.as(IdentifierTypeSyntax.self),
           identifierType.name.text.hasSuffix("?") {
            let unwrapped = String(identifierType.name.text.dropLast())
            return TypeSyntax(stringLiteral: unwrapped)
        }
        return type
    }

    /// Determine access levels for generated members based on the type's access level
    static func determineAccessLevels(of declaration: some DeclGroupSyntax) -> AccessLevels {
        let typeAccessLevel = getTypeAccessLevel(of: declaration)

        switch typeAccessLevel {
        case "open":
            return AccessLevels(
                properties: "public",      // Scene protocol requires public
                methods: "open",           // Allow overriding in subclasses
                initializers: "public"     // Scene creation should be public
            )
        case "public":
            return AccessLevels(
                properties: "public",      // Scene protocol requires public
                methods: "public",         // Public API
                initializers: "public"     // Scene creation should be public
            )
        case "internal":
            return AccessLevels(
                properties: "public",      // Scene protocol still requires public
                methods: "internal",       // Internal usage only
                initializers: "internal"   // Internal scene creation
            )
        case "fileprivate":
            return AccessLevels(
                properties: "fileprivate", // Limited to file
                methods: "fileprivate",    // Limited to file
                initializers: "fileprivate" // Limited to file
            )
        case "private":
            return AccessLevels(
                properties: "private",     // Very limited scope
                methods: "private",        // Very limited scope
                initializers: "private"    // Very limited scope
            )
        default:
            return AccessLevels(
                properties: "public",      // Default: Scene protocol compliance
                methods: "internal",       // Default: internal methods
                initializers: "internal"   // Default: internal creation
            )
        }
    }

    /// Get the access level of a type declaration
    static func getTypeAccessLevel(of declaration: some DeclGroupSyntax) -> String {
        // Check if the type has explicit access modifiers
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            for modifier in classDecl.modifiers {
                switch modifier.name.text {
                case "open":
                    return "open"
                case "public":
                    return "public"
                case "internal":
                    return "internal"
                case "fileprivate":
                    return "fileprivate"
                case "private":
                    return "private"
                default:
                    continue
                }
            }
        } else if let structDecl = declaration.as(StructDeclSyntax.self) {
            for modifier in structDecl.modifiers {
                switch modifier.name.text {
                case "public":
                    return "public"
                case "internal":
                    return "internal"
                case "fileprivate":
                    return "fileprivate"
                case "private":
                    return "private"
                default:
                    continue
                }
            }
        } else if let actorDecl = declaration.as(ActorDeclSyntax.self) {
            for modifier in actorDecl.modifiers {
                switch modifier.name.text {
                case "public":
                    return "public"
                case "internal":
                    return "internal"
                case "fileprivate":
                    return "fileprivate"
                case "private":
                    return "private"
                default:
                    continue
                }
            }
        }

        // Default to internal if no explicit access modifier
        return "internal"
    }
}

/// Access levels for different member types
struct AccessLevels {
    let properties: String      // Usually public for Scene protocol conformance
    let methods: String         // Can be internal/public based on intended usage
    let initializers: String    // Usually public for Scene creation
}