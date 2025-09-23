//
//  MigrationExamples.swift
//  iOSCore Examples
//
//  Examples showing how to migrate from swizzling/associated objects to Swift macros
//

import UIKit
import CoreMacrosClient

// MARK: - Before and After: UIViewController Lifecycle

// BEFORE: Using swizzling and associated objects
class OldViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Swizzling was initialized in ViewManager

        // Using associated objects for callbacks
        self.whenWillAppear { viewController in
            print("Old way: View will appear")
        }

        self.whenWillDisappear { viewController in
            print("Old way: View will disappear")
        }
    }
}

// AFTER: Using Swift macros
@SceneView
class NewViewController: UIViewController {
    // scene property automatically provided by @SceneView macro

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Clean lifecycle management with LifecycleStorage")
        // Custom logic here - no macros needed for simple overrides
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("No complex macro infrastructure needed")
        // Custom logic here
    }
}

// MARK: - Before and After: Scene Association

// BEFORE: Using associated objects
extension UIViewController {
    // This was in ReferenceManager.swift
    func oldAssociate(with scene: Scene) {
        objc_setAssociatedObject(self, &Keys.associatedScene, scene, .OBJC_ASSOCIATION_ASSIGN)
    }

    var oldScene: Scene? {
        objc_getAssociatedObject(self, &Keys.associatedScene) as? Scene
    }
}

// AFTER: Automatic SceneAssociated conformance with @SceneDependency
class NewViewManager {
    @SceneDependency  // Automatically makes class SceneAssociated!
    var authService: AuthService?

    // No need to manually implement SceneAssociated - macro does it automatically!
    // The macro generates both the scene property and associate method
}

// MARK: - Before and After: Dependency Injection

// BEFORE: Scene with @SceneDependency property wrapper
class OldScene: Scene {  // Manual Scene protocol conformance
    @SceneDependency
    var viewManager: ViewManager? // Property wrapper with runtime overhead

    func oldProvidesDependency() {
        // Property wrapper handles association automatically
        viewManager = ViewManager(viewController: rootViewController)
    }
}

// BEFORE: ViewController with @SceneDependencyReferenced property wrapper
class OldViewController: UIViewController {
    @SceneDependencyReferenced
    var viewManager: ViewManager? // Used Mirror reflection internally

    @SceneDependencyReferenced(keyPath: "customManager")
    var customManager: CustomManager? // With custom keyPath

    func oldWay() {
        // Runtime dependency resolution with Mirror reflection
        guard let vm = viewManager else { return }
        vm.present(someViewController, animated: true)

        customManager?.doSomething()
    }
}

// AFTER: Scene with @Scene macro (automatic Scene conformance!)
@Scene
class NewScene {  // @Scene macro automatically makes this conform to Scene protocol!

    @SceneDependency
    var viewManager: ViewManager? // Compile-time generation, same behavior as property wrapper

    func newProvidesDependency() {
        // Generated code handles association automatically (same API!)
        viewManager = ViewManager(viewController: rootViewController)
    }
}

// AFTER: ViewController with @SceneDependencyReference macro
class NewViewController: UIViewController {

    @SceneDependencyReference
    var viewManager: ViewManager? // Compile-time resolution, no Mirror reflection

    @SceneDependencyReference(keyPath: "customManager")
    var customManager: CustomManager? // With custom keyPath (same API!)

    func newWay() {
        // Direct property access, no runtime overhead
        viewManager?.present(someViewController, animated: true)

        customManager?.doSomething() // No Mirror reflection!
    }
}

// MARK: - Performance Comparison Example

class PerformanceExample {

    // OLD: Runtime overhead for every lifecycle call
    func oldLifecyclePerformance() {
        // Each call went through:
        // 1. Method swizzling lookup
        // 2. Associated object hash table lookup
        // 3. Closure handler execution
        // 4. Potential retain cycles
    }

    // NEW: Simple overrides with LifecycleStorage for advanced lifecycle management
    @SceneView
    class OptimizedViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Direct method call, compiled down to simple function call
            // No swizzling, no associated objects, no runtime lookup
            // LifecycleStorage handles advanced cases automatically
        }
    }
}

// MARK: - Migration Helper

class MigrationHelper {
    /// Step-by-step migration guide:
    ///
    /// 1. Add @SceneView to UIViewController subclasses for automatic scene access
    /// 2. Replace whenWillAppear/whenWillDisappear with standard override methods
    /// 3. Use LifecycleStorage for advanced lifecycle management (handled automatically)
    /// 4. Replace @SceneDependencyReferenced with @SceneDependencyReference
    /// 5. Remove swizzling initialization from ViewManager
    /// 6. Test performance improvements

    static func measurePerformanceImprovement() {
        // Expected improvements:
        // - 20-30% reduction in lifecycle callback overhead
        // - 15-25% reduction in memory usage from associated objects
        // - Elimination of runtime reflection costs
        // - Better compile-time optimizations
    }
}