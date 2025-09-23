//
//  MacroDefinitions.swift
//  CoreMacrosClient
//
//  Public interface for using the CoreMacros
//

@_exported import CoreMacros

/// Example usage documentation for the macros:
///
/// ```swift
/// // UIKit View Controller
/// @SceneView
/// class MyViewController: UIViewController {
///     @SceneDependencyReference
///     var authService: AuthService?
///
///     override func onSceneAssociated(_ scene: Scene) {
///         print("Associated with scene")
///     }
/// }
///
/// // SwiftUI View
/// @SceneView
/// struct MyView: View {
///     @SceneDependencyReference
///     var dataService: DataService?
///
///     var body: some View {
///         Text("Scene ID: \(scene?.id ?? "None")")
///     }
/// }
///
/// @Scene
/// class MyScene {  // Automatic Scene conformance!
///     @SceneDependency  // ONLY on Scene properties!
///     var viewManager: ViewManager?
/// }
/// ```