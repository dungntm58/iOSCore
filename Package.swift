// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.iOS(.v13), .tvOS(.v13)],
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
            targets: ["CoreRepositoryRequest"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            name: "Alamofire",
            url: "https://github.com/Alamofire/Alamofire",
            .upToNextMajor(from: "5.0.0")),
        .package(
            name: "CombineExt",
            url: "https://github.com/CombineCommunity/CombineExt",
            .upToNextMajor(from: "1.5.1")),
        .package(
            name: "DifferenceKit",
            url: "https://github.com/ra1028/DifferenceKit",
            .upToNextMajor(from: "1.2.0")),
        .package(
            name: "Realm",
            url: "https://github.com/realm/realm-cocoa",
            from: "10.18.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreAPNS",
            path: "Sources/APNS",
            exclude: ["Rx"],
            sources: [
                "Shared",
                "Combine"
            ]
        ),
        .target(
            name: "CoreBase",
            path: "Sources/Base",
            exclude: [
                "Rx",
                "Shared/ReduxExtension",
                "Combine/ReduxExtension"
            ],
            sources: [
                "Shared",
                "Combine"
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
            ]
        ),
        .target(
            name: "CoreRealmDataStore",
            dependencies: [
                .product(name: "RealmSwift", package: "Realm"),
                .target(name: "CoreRepositoryDataStore")
            ],
            path: "Sources/RealmDataStore"
        ),
        .target(
            name: "CoreRedux",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "Sources/Redux",
            exclude: [
                "Rx",
                "Shared/List",
                "Combine/List"
            ],
            sources: [
                "Shared/Basics",
                "Combine/Basics"
            ]),
        .target(
            name: "CoreReduxList",
            dependencies: [
                .target(name: "CoreRedux")
            ],
            path: "Sources/Redux",
            exclude: [
                "Rx",
                "Shared/Basics",
                "Combine/Basics"
            ],
            sources: [
                "Shared/List",
                "Combine/List"
            ]),
        .target(
            name: "CoreRepository",
            path: "Sources/Repository",
            exclude: [
                "Rx",
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
            ]),
        .target(
            name: "CoreRepositoryDataStore",
            dependencies: [
                .target(name: "CoreRepository")
            ],
            path: "Sources/Repository",
            exclude: [
                "Rx",
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
            ]),
        .target(
            name: "CoreRepositoryLocal",
            dependencies: [
                .target(name: "CoreRepository"),
                .target(name: "CoreRepositoryDataStore")
            ],
            path: "Sources/Repository",
            exclude: [
                "Rx",
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
            ]),
        .target(
            name: "CoreRepositoryRemote",
            dependencies: [
                .target(name: "CoreRepository"),
                .target(name: "CoreRepositoryRequest")
            ],
            path: "Sources/Repository",
            exclude: [
                "Rx",
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
                "Rx",
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
            ]),
        .target(
            name: "CoreRepositoryRequest",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .target(name: "CoreRepository")
            ],
            path: "Sources/Repository",
            exclude: [
                "Rx",
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
            ])
    ],
    swiftLanguageVersions: [.v5]
)
