// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Core",
    platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CoreAPNS",
            targets: ["CoreAPNS"]),
        .library(
            name: "CoreBase",
            targets: ["CoreBase"]),
        .library(
            name: "CoreDataStore",
            targets: ["CoreDataStore"]),
        .library(
            name: "CoreRealmDataStore",
            targets: ["CoreRealmDataStore"]),
        .library(
            name: "CoreRedux",
            targets: ["CoreRedux"]),
        .library(
            name: "CoreReduxList",
            targets: ["CoreReduxList"]),
        .library(
            name: "CoreRepository",
            targets: ["CoreRepository"]),
        .library(
            name: "CoreRepositoryDataStore",
            targets: ["CoreRepositoryDataStore"]),
        .library(
            name: "CoreRepositoryLocal",
            targets: ["CoreRepositoryLocal"]),
        .library(
            name: "CoreRepositoryRemote",
            targets: ["CoreRepositoryRemote"]),
        .library(
            name: "CoreRepositoryRequest",
            targets: ["CoreRepositoryRequest"]),
        .library(
            name: "CoreMacros",
            targets: ["CoreMacros"]),
        .library(
            name: "CoreMacrosClient",
            targets: ["CoreMacrosClient"]),
        .library(
            name: "CoreMacroProtocols",
            targets: ["CoreMacroProtocols"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            .upToNextMajor(from: "5.0.0")),
        .package(
            url: "https://github.com/CombineCommunity/CombineExt",
            .upToNextMajor(from: "1.5.1")),
        .package(
            url: "https://github.com/realm/realm-cocoa",
            from: "10.18.0"),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "510.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreAPNS",
            path: "Sources/APNS",
            sources: [
                "Shared",
                "Combine"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("UserNotifications")
            ]
        ),
        .target(
            name: "CoreBase",
            dependencies: [
                .target(name: "CoreMacrosClient"),
                .target(name: "CoreMacroProtocols")
            ],
            path: "Sources/Base",
            exclude: [
                "Shared/ReduxExtension",
                "Combine/ReduxExtension"
            ],
            sources: [
                "Shared",
                "Combine"
            ],
            swiftSettings: [
                .defaultIsolation(nil) // Disables default MainActor isolation
            ]
        ),
        .target(
            name: "CoreDataStore",
            dependencies: [
                .target(name: "CoreRepositoryDataStore")
            ],
            path: "Sources/CoreDataStore",
            resources: [
                .process("Model/MetaModel.xcdatamodeld")
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        ),
        .target(
            name: "CoreRealmDataStore",
            dependencies: [
                .product(name: "RealmSwift", package: "realm-cocoa"),
                .target(name: "CoreRepositoryDataStore")
            ],
            path: "Sources/RealmDataStore",
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        ),
        .target(
            name: "CoreRedux",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "Sources/Redux",
            exclude: [
                "Shared/List",
                "Combine/List"
            ],
            sources: [
                "Shared/Basics",
                "Combine/Basics"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreReduxList",
            dependencies: [
                .target(name: "CoreRedux")
            ],
            path: "Sources/Redux",
            exclude: [
                "Shared/Basics",
                "Combine/Basics"
            ],
            sources: [
                "Shared/List",
                "Combine/List"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepository",
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics/Identifiable.swift",
                "Shared/DataStore",
                "Shared/Local",
                "Shared/Remote",
                "Shared/RemoteLocal",
                "Shared/Request",
                "Combine/DataStore",
                "Combine/Local",
                "Combine/Remote",
                "Combine/RemoteLocal",
                "Combine/Request"
            ],
            sources: [
                "Shared/Basics",
                "Combine/Basics"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepositoryDataStore",
            dependencies: [
                .target(name: "CoreRepository")
            ],
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics",
                "Shared/Local",
                "Shared/Remote",
                "Shared/RemoteLocal",
                "Shared/Request",
                "Combine/Basics",
                "Combine/Local",
                "Combine/Remote",
                "Combine/RemoteLocal",
                "Combine/Request"
            ],
            sources: [
                "Shared/DataStore",
                "Combine/DataStore"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepositoryLocal",
            dependencies: [
                .target(name: "CoreRepository"),
                .target(name: "CoreRepositoryDataStore")
            ],
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics",
                "Shared/DataStore",
                "Shared/Remote",
                "Shared/RemoteLocal",
                "Shared/Request",
                "Combine/Basics",
                "Combine/DataStore",
                "Combine/Remote",
                "Combine/RemoteLocal",
                "Combine/Request"
            ],
            sources: [
                "Shared/Local",
                "Combine/Local"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepositoryRemote",
            dependencies: [
                .target(name: "CoreRepository"),
                .target(name: "CoreRepositoryRequest")
            ],
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics",
                "Shared/DataStore",
                "Shared/Local",
                "Shared/RemoteLocal",
                "Shared/Request",
                "Combine/Basics",
                "Combine/DataStore",
                "Combine/Local",
                "Combine/RemoteLocal",
                "Combine/Request"
            ],
            sources: [
                "Shared/Remote",
                "Combine/Remote"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepositoryRemoteLocal",
            dependencies: [
                .target(name: "CoreRepository"),
                .target(name: "CoreRepositoryDataStore"),
                .target(name: "CoreRepositoryRequest")
            ],
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics",
                "Shared/DataStore",
                "Shared/Local",
                "Shared/Remote",
                "Shared/Request",
                "Combine/Basics",
                "Combine/DataStore",
                "Combine/Local",
                "Combine/Remote",
                "Combine/Request"
            ],
            sources: [
                "Shared/RemoteLocal",
                "Combine/RemoteLocal"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .target(
            name: "CoreRepositoryRequest",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .target(name: "CoreRepository")
            ],
            path: "Sources/Repository",
            exclude: [
                "Shared/Basics",
                "Shared/DataStore",
                "Shared/Local",
                "Shared/Remote",
                "Shared/RemoteLocal",
                "Combine/Basics",
                "Combine/DataStore",
                "Combine/Local",
                "Combine/Remote",
                "Combine/RemoteLocal"
            ],
            sources: [
                "Shared/Request",
                "Combine/Request"
            ],
            swiftSettings: [
                .defaultIsolation(nil)
            ]),
        .macro(
            name: "CoreMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .target(name: "CoreMacroProtocols")
            ],
            path: "Sources/CoreMacrosPlugin",
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        ),
        .target(
            name: "CoreMacros",
            dependencies: [
                .target(name: "CoreMacrosPlugin"),
                .target(name: "CoreMacroProtocols")
            ],
            path: "Sources/CoreMacros",
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        ),
        .target(
            name: "CoreMacrosClient",
            dependencies: [
                .target(name: "CoreMacros")
            ],
            path: "Sources/CoreMacrosClient",
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        ),
        .target(
            name: "CoreMacroProtocols",
            path: "Sources/CoreMacroProtocols",
            swiftSettings: [
                .defaultIsolation(nil)
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
