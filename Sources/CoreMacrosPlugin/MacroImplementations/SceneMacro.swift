//
//  SceneMacro.swift
//  CoreMacrosPlugin
//
//  Implementation of @Scene macro for automatic Scene protocol conformance
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

/// Errors that can occur during Scene macro expansion
enum SceneMacroError: Error, DiagnosticMessage {
    case multipleViewManagableProperties(String)

    var message: String {
        switch self {
        case .multipleViewManagableProperties(let propertyNames):
            return "Scene can have at most one ViewManagable property. Found multiple: \(propertyNames)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "SceneMacro", id: "validation")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

/// Macro that generates compile-time dependency resolution for Scene classes
public struct SceneMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Determine the access levels for different member types
        let accessLevels = MacroUtilities.determineAccessLevels(of: declaration)

        // Check what's already defined in the type
        let existingMembers = analyzeExistingMembers(in: declaration)

        // Find all dependencies (both explicit @SceneDependency and auto-detected)
        let allDependencies = findAllSceneDependencies(in: declaration)

        // Find ViewManagable properties and validate there's at most one
        let viewManagableProperties = findViewManagableProperties(in: declaration)

        // Validate maximum 1 ViewManagable property per scene
        if viewManagableProperties.count > 1 {
            let propertyNames = viewManagableProperties.map { $0.name }.joined(separator: ", ")
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: SceneMacroError.multipleViewManagableProperties(propertyNames)
                )
            )
            throw SceneMacroError.multipleViewManagableProperties(propertyNames)
        }

        let viewManagableProperty = viewManagableProperties.first

        // Generate switch cases for each dependency
        let switchCases = allDependencies.map { property in
            let awaitKeyword = isAsyncProperty(property.name, in: declaration) ? "await " : ""
            return """
            case "\(property.name)":
                let dependency = \(awaitKeyword)\(property.name) as? T
                if let dependency = dependency, let sceneDependency = dependency as? any CoreMacroProtocols.SceneDependency {
                    CoreMacroProtocols.SceneAssociationRegistry.shared.associate(sceneDependency, with: self, token: CoreMacroProtocols.__sceneDependencyMacroToken())
                }
                return dependency
            """
        }.joined(separator: "\n            ")

        let resolutionMethod = {
            if allDependencies.isEmpty {
                return """
                \(accessLevels.methods) func resolveDependency<T>(for keyPath: String?, type: T.Type) async -> T? {
                    return nil
                }
                """
            } else {
                // Generate type-based lookup cases for when keyPath is nil
                let typeLookupCases = allDependencies.map { property in
                let awaitKeyword = isAsyncProperty(property.name, in: declaration) ? "await " : ""
                return """
                if let value = \(awaitKeyword)\(property.name) as? T {
                    if let sceneDependency = value as? any CoreMacroProtocols.SceneDependency {
                        CoreMacroProtocols.SceneAssociationRegistry.shared.associate(sceneDependency, with: self, token: CoreMacroProtocols.__sceneDependencyMacroToken())
                    }
                    return value
                }
                """
                }.joined(separator: "\n                ")

                return """
                \(accessLevels.methods) func resolveDependency<T>(for keyPath: String?, type: T.Type) async -> T? {
                    if let keyPath = keyPath {
                        switch keyPath {
                \(switchCases)
                        default:
                            return nil
                        }
                    } else {
                \(typeLookupCases)
                        return nil
                    }
                }
                """
            }
        }()

        var declarations: [DeclSyntax] = []

        // Generate required Scene protocol properties if missing
        if !existingMembers.hasManagedContext {
            declarations.append("""
                \(raw: accessLevels.properties) let managedContext = ManagedSceneContext()
                """)
        }

        if !existingMembers.hasId {
            declarations.append("""
                \(raw: accessLevels.properties) let id = UUID().uuidString
                """)
        }

        // Always generate dependency resolution method (may be updated)
        declarations.append(DeclSyntax(stringLiteral: resolutionMethod))

        // Generate HasViewManagable conformance if ViewManagable property is found
        if let viewManagableProperty = viewManagableProperty, !existingMembers.hasAnyViewManager {
            declarations.append("""
                \(raw: accessLevels.properties) var anyViewManager: ViewManagable? {
                    return \(raw: viewManagableProperty.name)
                }
                """)
        }

        // Generate dependency setup method if there are dependencies
        if !allDependencies.isEmpty {
            let associationCalls = allDependencies.map { property in
                let awaitKeyword = isAsyncProperty(property.name, in: declaration) ? "await " : ""
                return """
                if let dependency = \(awaitKeyword)\(property.name) as? any CoreMacroProtocols.SceneDependency {
                    CoreMacroProtocols.SceneAssociationRegistry.shared.associate(dependency, with: self, token: CoreMacroProtocols.__sceneDependencyMacroToken())
                }
                """
            }.joined(separator: "\n            ")

            declarations.append("""
                \(raw: accessLevels.methods) func __setupSceneDependencies() async {
                    \(raw: associationCalls)
                }
                """)

            // Generate compiler warnings if user has manual implementations but dependencies exist
            if existingMembers.hasPrepare {
                let warning = """
                #warning("Scene has @SceneDependency properties and a manual prepareSelf() implementation. Call 'await __setupSceneDependencies()' at the beginning of your prepareSelf method to ensure dependencies are associated with this scene.")
                """
                declarations.append(DeclSyntax(stringLiteral: warning))
            }
        }

        // Generate default lifecycle methods if missing
        if !existingMembers.hasPerform {
            declarations.append("""
                    \(raw: accessLevels.methods) func perform(with userInfo: Any?) async {
                    }
                """)
        }

        if !existingMembers.hasPrepare {
            let prepareBody = allDependencies.isEmpty ? "" : """

                // Associate dependencies with this scene
                await __setupSceneDependencies()
            """

            declarations.append("""
                \(raw: accessLevels.methods) func prepareSelf() async {\(raw: prepareBody)
                }
                """)
        }

        if !existingMembers.hasPrepareFor {
            declarations.append("""
                \(raw: accessLevels.methods) func prepare(for scene: Scene) async {
                }
                """)
        }

        if !existingMembers.hasOnDetach {
            declarations.append("""
                \(raw: accessLevels.methods) func onDetach() async {
                }
                """)
        }

        // Generate debug deinit if missing
        if !existingMembers.hasDeinit {
            declarations.append("""
                #if !RELEASE && !PRODUCTION
                deinit {
                    print("Deinit", String(describing: Self.self))
                }
                #endif
                """)
        }

        return declarations
    }

    private static func findAllSceneDependencies(in declaration: some DeclGroupSyntax) -> [PropertyInfo] {
        var properties: [PropertyInfo] = []

        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                // Check if this property has @SceneDependency attribute (explicit)
                let hasSceneDependency = varDecl.attributes.contains { attribute in
                    if case .attribute(let attr) = attribute,
                       let identifier = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
                        return identifier == "SceneDependency"
                    }
                    return false
                }

                if let binding = varDecl.bindings.first,
                   let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                   let typeAnnotation = binding.typeAnnotation?.type {

                    // Include if it has @SceneDependency attribute OR the type conforms to SceneDependency
                    let shouldBeSceneDependency = hasSceneDependency || isTypeSceneDependency(typeAnnotation)

                    if shouldBeSceneDependency {
                        properties.append(PropertyInfo(name: identifier.text, type: typeAnnotation))
                    }
                }
            }
        }

        return properties
    }

    /// Check if a type conforms to SceneDependency protocol or is marked with @SceneDependency macro
    /// This checks for explicit conformance and excludes system types
    private static func isTypeSceneDependency(_ type: TypeSyntax) -> Bool {
        let typeString = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseType = typeString.replacingOccurrences(of: "?", with: "").replacingOccurrences(of: "!", with: "")

        // Skip system/primitive types that shouldn't be dependencies
        let excludePatterns = [
            "UIViewController", "UIView", "UILabel", "UIButton", "UIImage",
            "String", "Int", "Double", "Float", "Bool", "Date", "URL", "Data",
            "Array", "Dictionary", "Set", "Optional", "Never", "Void"
        ]

        // First check if it should be excluded
        for exclude in excludePatterns {
            if baseType.contains(exclude) {
                return false
            }
        }

        // Check for explicit SceneDependency protocol conformance
        if baseType.contains("SceneDependency") {
            return true
        }

        // Special case: ViewManagable types are dependencies
        if baseType.contains("ViewManagable") || baseType.contains("ViewManager") {
            return true
        }

        // For custom types (not system types), assume they might be SceneDependency conforming types
        // This allows auto-detection of manually conforming types
        // The final validation happens at compile time
        return !isSystemType(baseType)
    }

    /// Check if a type is a system/framework type that shouldn't be a dependency
    private static func isSystemType(_ typeString: String) -> Bool {
        let systemPrefixes = [
            "UI", "NS", "CG", "CA", "CF", "Core", "Foundation", "SwiftUI", "Combine",
            "String", "Int", "Double", "Float", "Bool", "Date", "URL", "Data",
            "Array", "Dictionary", "Set", "Optional", "Never", "Void", "Task", "AsyncSequence"
        ]

        return systemPrefixes.contains { typeString.hasPrefix($0) }
    }

    private static func findViewManagableProperties(in declaration: some DeclGroupSyntax) -> [PropertyInfo] {
        var viewManagableProperties: [PropertyInfo] = []

        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                // Check if this property has @SceneDependency attribute
                let hasSceneDependency = varDecl.attributes.contains { attribute in
                    if case .attribute(let attr) = attribute,
                       let identifier = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
                        return identifier == "SceneDependency"
                    }
                    return false
                }

                if hasSceneDependency,
                   let binding = varDecl.bindings.first,
                   let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                   let typeAnnotation = binding.typeAnnotation?.type {

                    // Check if the type contains "ViewManager" (indicating it conforms to ViewManagable)
                    let typeString = typeAnnotation.description
                    if typeString.contains("ViewManager") {
                        viewManagableProperties.append(PropertyInfo(name: identifier.text, type: typeAnnotation))
                    }
                }
            }
        }

        return viewManagableProperties
    }

    private static func findViewManagableProperty(in declaration: some DeclGroupSyntax) -> PropertyInfo? {
        findViewManagableProperties(in: declaration).first
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        var extensions: [ExtensionDeclSyntax] = []

        // Find ViewManagable properties and validate there's at most one
        let viewManagableProperties = findViewManagableProperties(in: declaration)

        // Validate maximum 1 ViewManagable property per scene
        if viewManagableProperties.count > 1 {
            let propertyNames = viewManagableProperties.map { $0.name }.joined(separator: ", ")
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: SceneMacroError.multipleViewManagableProperties(propertyNames)
                )
            )
            throw SceneMacroError.multipleViewManagableProperties(propertyNames)
        }

        // Generate Scene protocol conformance
        var conformanceTypes = ["Scene"]

        // Check if the type has a ViewManagable property and should conform to HasViewManagable
        if !viewManagableProperties.isEmpty {
            conformanceTypes.append("HasViewManagable")
        }

        let conformanceString = conformanceTypes.joined(separator: ", ")
        let sceneConformance: DeclSyntax =
        """
        extension \(type.trimmed): \(raw: conformanceString) {}
        """

        if let extensionDecl = sceneConformance.as(ExtensionDeclSyntax.self) {
            extensions.append(extensionDecl)
        }

        return extensions
    }

}

private struct PropertyInfo {
    let name: String
    let type: TypeSyntax?
}

private struct ExistingMembers {
    let hasManagedContext: Bool
    let hasId: Bool
    let hasInitializer: Bool
    let hasPerform: Bool
    let hasPrepare: Bool  // prepareSelf()
    let hasPrepareFor: Bool  // prepare(for scene: Scene)
    let hasOnDetach: Bool
    let hasDeinit: Bool
    let hasResolveDependency: Bool
    let hasAnyViewManager: Bool
}

private extension SceneMacro {
    static func analyzeExistingMembers(in declaration: some DeclGroupSyntax) -> ExistingMembers {
        var hasManagedContext = false
        var hasId = false
        var hasInitializer = false
        var hasPerform = false
        var hasPrepare = false
        var hasPrepareFor = false
        var hasOnDetach = false
        var hasDeinit = false
        var hasResolveDependency = false
        var hasAnyViewManager = false

        for member in declaration.memberBlock.members {
            // Check for properties
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                for binding in varDecl.bindings {
                    if let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier {
                        switch identifier.text {
                        case "managedContext":
                            hasManagedContext = true
                        case "id":
                            hasId = true
                        case "anyViewManager":
                            hasAnyViewManager = true
                        default:
                            break
                        }
                    }
                }
            }

            // Check for functions
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                switch funcDecl.name.text {
                case "perform":
                    hasPerform = true
                case "prepareSelf":
                    hasPrepare = true
                case "prepare":
                    // Check if it's prepare(for scene: Scene)
                    if funcDecl.signature.parameterClause.parameters.count == 1 {
                        hasPrepareFor = true
                    }
                case "onDetach":
                    hasOnDetach = true
                case "resolveDependency":
                    hasResolveDependency = true
                default:
                    break
                }
            }

            // Check for initializer
            if member.decl.as(InitializerDeclSyntax.self) != nil {
                hasInitializer = true
            }

            // Check for deinit
            if member.decl.as(DeinitializerDeclSyntax.self) != nil {
                hasDeinit = true
            }
        }

        return ExistingMembers(
            hasManagedContext: hasManagedContext,
            hasId: hasId,
            hasInitializer: hasInitializer,
            hasPerform: hasPerform,
            hasPrepare: hasPrepare,
            hasPrepareFor: hasPrepareFor,
            hasOnDetach: hasOnDetach,
            hasDeinit: hasDeinit,
            hasResolveDependency: hasResolveDependency,
            hasAnyViewManager: hasAnyViewManager
        )
    }

    /// Check if a property might be async (has @AsyncInit or async getter)
    static func isAsyncProperty(_ propertyName: String, in declaration: some DeclGroupSyntax) -> Bool {
        for member in declaration.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                if let binding = varDecl.bindings.first,
                   let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier {
                    if identifier.text == propertyName {

                        // Check if this property has @AsyncInit attribute
                        let hasAsyncInit = varDecl.attributes.contains { attribute in
                            if case .attribute(let attr) = attribute,
                               let identifier = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text {
                                return identifier == "AsyncInit"
                            }
                            return false
                        }

                        if hasAsyncInit {
                            return true
                        }

                        // Check if property has explicit async getter
                        if let accessorBlock = binding.accessorBlock {
                            // Use string matching for async detection as it's more reliable
                            let accessorText = accessorBlock.description
                            if accessorText.contains("get async") || accessorText.contains("async get") {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
