//
//  AsyncInitMacro.swift
//  CoreMacrosPlugin
//
//  Implementation of @AsyncInit macro for actor properties
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Macro that transforms actor properties to use AsyncInit value wrapper
///
/// Transforms:
/// ```swift
/// @AsyncInit var viewModel: SwitchViewModel?
/// ```
///
/// Into:
/// ```swift
/// private let _viewModel: AsyncInit<SwitchViewModel>
///
/// private var viewModel: SwitchViewModel {
///     get async {
///         await _viewModel.value
///     }
/// }
/// ```
public struct AsyncInitMacro: AccessorMacro, PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {

        let (identifier, isOptional) = try extractPropertyInfo(from: declaration)
        let accessor = isOptional ? "?" : ""

        let getter: AccessorDeclSyntax = """
        get async {
            await _\(identifier)\(raw: accessor).value
        }
        """

        return [getter]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        let (identifier, type, isOptional) = try extractFullPropertyInfo(from: declaration)
        let propertyName = identifier.text
        let unwrappedType = MacroUtilities.unwrapOptionalType(type)
        let optionalSuffix = isOptional ? "?" : ""

        let asyncInitProperty: DeclSyntax = """
        private var _\(raw: propertyName): AsyncInit<\(unwrappedType)>\(raw: optionalSuffix)
        """

        return [asyncInitProperty]
    }

    // Helper functions
    private static func extractPropertyInfo(from declaration: some DeclSyntaxProtocol) throws -> (TokenSyntax, Bool) {
        let (identifier, _, isOptional) = try extractFullPropertyInfo(from: declaration)
        return (identifier, isOptional)
    }

    private static func extractFullPropertyInfo(from declaration: some DeclSyntaxProtocol) throws -> (TokenSyntax, TypeSyntax, Bool) {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let type = binding.typeAnnotation?.type else {
            throw AsyncInitMacroError.invalidDeclaration
        }

        let isOptional = type.as(OptionalTypeSyntax.self) != nil ||
                        type.description.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("?")

        return (identifier, type, isOptional)
    }
}

enum AsyncInitMacroError: Error, DiagnosticMessage {
    case invalidDeclaration

    var message: String {
        switch self {
        case .invalidDeclaration:
            return "@AsyncInit can only be applied to variable declarations with explicit types"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "AsyncInitMacro", id: "validation")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}