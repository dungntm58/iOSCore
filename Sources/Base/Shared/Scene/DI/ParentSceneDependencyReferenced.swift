//
//  ParentSceneDependencyReferenced.swift
//  CoreBase
//
//  Created by Robert on 7/22/20.
//

import Foundation
import UIKit

// @propertyWrapper
// final public class ParentSceneDependencyReferenced<S>: SceneDependencyObservable {

//     public static subscript<EnclosingSelf>(
//         _enclosingInstance observed: EnclosingSelf,
//         wrapped wrappedKeyPath: KeyPath<EnclosingSelf, S?>,
//         storage storageKeyPath: KeyPath<EnclosingSelf, ParentSceneDependencyReferenced<S>>
//     ) -> S? where EnclosingSelf: SceneAssociated {
//         let sceneDependencyReferenced = observed[keyPath: storageKeyPath]
//         sceneDependencyReferenced.observed = observed
//         if S.self is AnyObject.Type,
//            let dependency = sceneDependencyReferenced.dependency {
//             return dependency
//         }
//         if S.self is AnyObject.Type,
//            let dependency = sceneDependencyReferenced.dependency {
//             return dependency
//         }
//         sceneDependencyReferenced.retrieveDependency()
//         return sceneDependencyReferenced.dependency
//     }

//     public init(keyPath: String? = nil) {
//         self.keyPath = keyPath.map { KeyPathValue.string($0) }
//     }

//     public init(keyPath: AnyKeyPath) {
//         self.keyPath = .concrete(keyPath)
//     }

//     deinit {
//         guard let scene else {
//             return
//         }
//         DependencyObservationCenter.default.unregister(scene: scene, dependencyRef: self)
//     }

//     private weak var observed: SceneAssociated?
//     private let keyPath: KeyPathValue?
//     private weak var scene: Scene? {
//         didSet {
//             guard let scene else {
//                 return
//             }
//             DependencyObservationCenter.default.register(scene: scene, dependencyRef: self)
//         }
//     }
//     private var dependency: S?

//     @available(*, unavailable, message: "@ParentSceneDependencyReferenced is only available on properties of UIViewController")
//     public var wrappedValue: S? {
//         fatalError()
//     }

//     public func updateChange(keyPath: AnyKeyPath) {
//         guard let kValue = self.keyPath else {
//             return updateDependency(keyPath: keyPath)
//         }
//         switch kValue {
//         case .string:
//             retrieveDependency()
//         case .concrete(let value):
//             if value == keyPath {
//                 updateDependency(keyPath: keyPath)
//             }
//         }
//     }

//     private func updateDependency(keyPath: AnyKeyPath) {
//         let dependency = scene?[keyPath: keyPath]
//         guard dependency is S? else {
//             return
//         }
//         self.dependency = dependency as? S
//     }

//     private func retrieveDependency() {
//         if let scene {
//             let dependency: S? = scene.getDependency(keyPath: keyPath)
//             return self.dependency = dependency
//         }
//         guard let scene = observed?.scene?.parent else { return }
//         self.scene = scene
//         let dependency: S? = scene.getDependency(keyPath: keyPath)
//         self.dependency = dependency
//     }
// }
