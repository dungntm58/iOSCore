# iOS Core

A comprehensive Swift framework for iOS development featuring scene-based architecture, dependency injection, and powerful macro-based code generation.

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013%2B%20%7C%20tvOS%2013%2B%20%7C%20macOS%2010.15%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

iOS Core provides a modern, Swift Concurrency-based architecture for iOS apps with:

- **Scene-Based Architecture**: Manage app flow with Scene protocol and automatic lifecycle management
- **Dependency Injection**: Type-safe dependency injection with automatic scene association
- **Swift Macros**: Reduce boilerplate with `@Scene`, `@SceneDependency`, and `@AsyncInit` macros
- **Repository Pattern**: Clean architecture with local/remote data management
- **Redux Integration**: State management with Combine-based Redux implementation
- **Data Persistence**: Core Data and Realm integration

## Requirements

- **iOS 13.0+** / tvOS 13.0+ / macOS 10.15+
- **Swift 6.2+**
- **Xcode 15.0+**

## Installation

### Swift Package Manager

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dungntm58/iOSCore.git", from: "1.0.0")
]
```

Or add it through Xcode: **File → Add Package Dependencies** and enter the repository URL.

## Architecture

### Scene-Based Architecture

The core of the framework is the Scene protocol, which represents a unit of app functionality:

```swift
import CoreMacros
import CoreBase

@Scene
actor LoginScene {
    @SceneDependency var authService: AuthService
    @AsyncInit var viewModel = LoginViewModel()

    func perform(with userInfo: Any?) async {
        // Scene logic here
        if await authService.isAuthenticated() {
            await switch(to: DashboardScene(), with: nil)
        }
    }
}
```

### Dependency Injection

Dependencies are automatically resolved and associated with their owning scene:

```swift
@SceneDependency
class AuthService {
    func authenticate(username: String, password: String) async -> Bool {
        // Can access the owning scene through `scene` property
        return true
    }
}
```

### Scene Views with Dependency References

Views can reference scene dependencies through the `@SceneDependencyReference` macro:

```swift
import SwiftUI
import CoreMacros

@SceneView
struct LoginView: View {
    @SceneDependencyReference var authService: AuthService?

    var body: some View {
        // Use authService here
    }
}
```

### Async Initialization

Handle async initialization cleanly with the `@AsyncInit` macro:

```swift
@AsyncInit var expensiveResource = await SomeExpensiveResource.create()
```

## Available Modules

### Core Modules

- **CoreBase**: Scene architecture and base utilities
- **CoreMacros**: Swift macros for reducing boilerplate
- **CoreMacroProtocols**: Protocols and types for macro system

### Repository & Data

- **CoreRepository**: Repository pattern implementation
- **CoreRepositoryLocal**: Local data repository support
- **CoreRepositoryRemote**: Remote API repository support
- **CoreRepositoryRequest**: HTTP request handling with Alamofire
- **CoreDataStore**: Core Data integration
- **CoreRealmDataStore**: Realm database integration

### State Management

- **CoreRedux**: Redux pattern with Combine
- **CoreReduxList**: List-specific Redux utilities

### Additional Features

- **CoreAPNS**: Push notification handling

## Quick Start

### 1. Create a Scene

```swift
import CoreMacros
import CoreBase

@Scene
actor WelcomeScene {
    func perform(with userInfo: Any?) async {
        print("Welcome scene is active!")

        // Navigate to next scene after 2 seconds
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await switch(to: LoginScene(), with: nil)
    }
}
```

### 2. Set up App Delegate

```swift
import UIKit
import CoreBase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private lazy var launcher: Launchable = WelcomeScene()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()

        Task { @MainActor in
            await launcher.launch()
        }

        return true
    }
}
```

### 3. Create Dependencies

```swift
@SceneDependency
class NetworkService {
    func fetchData() async -> Data? {
        // Network implementation
        return nil
    }
}

@Scene
actor DataScene {
    @SceneDependency var networkService: NetworkService

    func perform(with userInfo: Any?) async {
        let data = await networkService.fetchData()
        // Process data...
    }
}
```

## Advanced Features

### Manual Scene Preparation

If you implement custom scene methods, the macro will provide compiler warnings with instructions:

```swift
@Scene
actor CustomScene {
    @SceneDependency var service: MyService

    // Manual implementation - you'll get a compiler warning to call __setupSceneDependencies()
    func prepareSelf() async {
        await __setupSceneDependencies()  // Associate dependencies
        // Your custom preparation logic
    }
}
```

### ViewManager Integration

Scenes can automatically conform to `HasViewManagable` when they have ViewManager properties:

```swift
@Scene
actor MyScene {
    @SceneDependency var viewManager: MyViewManager  // ViewManager conforms to ViewManagable

    // Automatically generates anyViewManager property
}
```

### Repository Pattern Example

```swift
import CoreRepository
import CoreRepositoryRemote

struct UserRepository: RemoteRepository {
    typealias Entity = User

    func fetch(byId id: String) async throws -> User? {
        // Remote fetch implementation
    }
}
```

## Macro Reference

### `@Scene`
- Generates Scene protocol conformance
- Creates dependency resolution system
- Provides lifecycle method implementations
- Handles ViewManager integration

### `@SceneDependency`
- Marks types as scene dependencies
- Generates SceneDependency protocol conformance
- Enables automatic scene association

### `@SceneDependencyReference`
- Used in views to reference scene dependencies
- Generates async getters that resolve through scene
- Validates SceneReferencing conformance

### `@AsyncInit`
- Handles async property initialization
- Generates Task-based initialization pattern
- Works with both optional and non-optional properties

### `@SceneView`
- Marks views that reference scene dependencies
- Provides SceneReferencing conformance

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Robert Nguyen** - [dungntm58](https://github.com/dungntm58)

---

For more detailed documentation and examples, check out the [Example project](Example/) included in this repository.