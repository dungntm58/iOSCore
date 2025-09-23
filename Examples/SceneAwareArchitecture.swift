//
//  SceneAwareArchitecture.swift
//  iOSCore Examples
//
//  Examples showing the new scene-aware architecture for both headed and headless scenes
//

import UIKit
import SwiftUI
import CoreMacrosClient

// MARK: - Scene Definitions

/// Example of a headed scene (with ViewManager)
@Scene
class LoginScene {
    @SceneDependency  // ✅ CORRECT - Property OF a Scene
    var viewManager: ViewManager?

    @SceneDependency  // ✅ CORRECT - Property OF a Scene
    var authService: AuthService?

    func performLogin() {
        // Use ViewManager if available (headed scene)
        if let viewManager = viewManager {
            let loginVC = LoginViewController()
            viewManager.present(loginVC, animated: true)
        }

        // Business logic works regardless (headless or headed)
        authService?.authenticate()
    }
}

/// Example of a headless scene (no ViewManager)
@Scene
class BackgroundTaskScene {
    @SceneDependency  // ✅ CORRECT - Property OF a Scene
    var dataService: DataService?

    @SceneDependency  // ✅ CORRECT - Property OF a Scene
    var networkManager: NetworkManager?

    // No ViewManager - this scene runs in background
    func processData() {
        dataService?.processInBackground()
        networkManager?.syncData()
    }
}

// MARK: - View Controllers with Scene Awareness

/// UIKit View Controller with automatic scene awareness
@SceneView
class LoginViewController: UIViewController {
    // scene property automatically available!
    // associateWithScene(_:) method automatically available!

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // Override this to perform setup when associated with a scene
    override func onSceneAssociated(_ scene: Scene) {
        print("LoginViewController associated with scene: \(scene.id)")

        // Can access scene dependencies directly through the scene
        if let loginScene = scene as? LoginScene {
            // Scene-specific setup
        }
    }

    @IBAction func loginTapped() {
        // Access scene to perform business logic
        if let loginScene = scene as? LoginScene {
            loginScene.performLogin()
        }
    }

    // Direct access to scene dependencies (alternative approach)
    @SceneDependencyReference
    var authService: AuthService?

    private func setupUI() {
        // UI setup
    }
}

/// Another UIKit view controller example
@SceneView
class DashboardViewController: UIViewController {

    @SceneDependencyReference
    var dataService: DataService?

    @SceneDependencyReference(keyPath: "viewManager")
    var viewManager: ViewManager?

    override func onSceneAssociated(_ scene: Scene) {
        print("Dashboard associated with scene: \(scene.id)")
        loadDashboardData()
    }

    private func loadDashboardData() {
        dataService?.loadDashboard { [weak self] data in
            DispatchQueue.main.async {
                self?.updateUI(with: data)
            }
        }
    }

    private func updateUI(with data: Any) {
        // Update dashboard UI
    }
}

// MARK: - SwiftUI Views with Scene Awareness

/// SwiftUI View with automatic scene awareness
@SceneView
struct LoginView: View {
    // scene property automatically available!

    @SceneDependencyReference
    var authService: AuthService?

    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)

            Button("Login") {
                // Access scene directly
                if let loginScene = scene as? LoginScene {
                    loginScene.performLogin()
                }

                // Or use dependency directly
                authService?.authenticate()
            }
        }
        .onAppear {
            // Scene is available when view appears
            setupForScene()
        }
    }

    private func setupForScene() {
        guard let scene = scene else { return }
        print("SwiftUI View associated with scene: \(scene.id)")
    }
}

/// Another SwiftUI View example
@SceneView
struct DashboardView: View {
    @SceneDependencyReference
    var dataService: DataService?

    @State private var dashboardData: Any?

    var body: some View {
        VStack {
            if let data = dashboardData {
                Text("Dashboard loaded")
                // Display dashboard content
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        dataService?.loadDashboard { [self] data in
            DispatchQueue.main.async {
                self.dashboardData = data
            }
        }
    }
}

// MARK: - Services (Dependencies used by Scenes)

/// Services used as dependencies by Scenes
/// They DON'T use @SceneDependency - that's only for Scene properties!
class AuthService {
    // Regular properties - no @SceneDependency here!
    var networkManager: NetworkManager?

    func authenticate() {
        networkManager?.post("/auth/login") { result in
            // Handle authentication
        }
    }
}

class DataService {
    // Regular properties - no @SceneDependency here!
    var cacheManager: CacheManager?

    func loadDashboard(completion: @escaping (Any) -> Void) {
        // Load dashboard data
    }

    func processInBackground() {
        // Background processing
    }
}

class NetworkManager {
    func post(_ endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Network request
    }

    func syncData() {
        // Sync data in background
    }
}

class CacheManager {
    // Cache implementation
}

// MARK: - Usage Examples

class SceneSetupExample {

    func createHeadedScene() -> LoginScene {
        // Create scene with ViewManager (headed)
        let scene = LoginScene()
        let rootVC = LoginViewController()

        // Create ViewManager and associate with scene
        let viewManager = ViewManager(viewController: rootVC)
        scene.viewManager = viewManager  // Scene dependency

        // ViewManager automatically registers all VCs - no manual association needed!
        // @SceneView macro handles scene discovery automatically

        return scene
    }

    func createHeadlessScene() -> BackgroundTaskScene {
        // Create scene without ViewManager (headless)
        let scene = BackgroundTaskScene()

        // Set up services only
        scene.dataService = DataService()
        scene.networkManager = NetworkManager()

        return scene
    }

    func demonstrateUIKitSceneAwareness() {
        let scene = createHeadedScene()
        let viewController = LoginViewController()

        // Present through ViewManager - automatic registration happens
        scene.viewManager?.present(viewController, animated: true)

        // viewController.scene is now automatically available!
        // No manual association needed - @SceneView macro handles discovery
        // All @SceneDependencyReference properties work automatically
    }

    func demonstrateSwiftUISceneAwareness() {
        let scene = createHeadedScene()
        let loginView = LoginView()

        // For SwiftUI, associate through ViewManager or environment
        // The @SceneView macro provides the scene property
        // SwiftUI views can access scene in their body

        // Example: Using with UIHostingController
        let hostingController = UIHostingController(rootView: loginView)
        scene.viewManager?.present(hostingController, animated: true)

        // The SwiftUI view will have access to scene dependencies
    }
}

// MARK: - Migration Benefits

/*

 CORRECT @SceneDependency USAGE:

 ✅ CORRECT: @SceneDependency is ONLY used on properties OF Scene classes
 @Scene
 class LoginScene {
     @SceneDependency var viewManager: ViewManager?    // ✅ Scene property
     @SceneDependency var authService: AuthService?    // ✅ Scene property
 }

 ❌ WRONG: @SceneDependency is NOT used on arbitrary service classes
 class AuthService {
     @SceneDependency var networkManager: NetworkManager?  // ❌ WRONG!
     var networkManager: NetworkManager?                   // ✅ Regular property
 }

 ARCHITECTURE BENEFITS:

 1. Clear Dependency Hierarchy:
    - Scenes provide dependencies using @SceneDependency
    - Services are regular classes with regular properties
    - View Controllers reference dependencies via @SceneDependencyReference

 2. @SceneView for Views:
    - Works with both UIKit ViewControllers and SwiftUI Views
    - Automatic scene discovery via ViewManagerRegistry
    - No manual association needed - just present through ViewManager
    - Override onSceneAssociated for UIKit custom setup
    - Clean scene reference without boilerplate

 3. Flexible Scene Types:
    - Headed scenes: Have ViewManager for UI
    - Headless scenes: Pure business logic, no UI

 4. Type-Safe Dependency Access:
    - @SceneDependencyReference for direct dependency access
    - scene property for scene-level operations
    - Compile-time validated

 5. Automatic Scene Discovery:
    - ViewManagerRegistry tracks VC-to-ViewManager relationships
    - @SceneView macro automatically finds the scene
    - No complex manual association logic in ViewManager
    - Works through view hierarchy and presentation relationships

 */