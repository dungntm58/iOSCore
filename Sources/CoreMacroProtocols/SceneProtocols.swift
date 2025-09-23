//
//  SceneProtocols.swift
//  CoreMacroProtocols
//
//  Scene management protocols and types
//

import Foundation
import Combine

// MARK: - Scene Management Types

@frozen
public enum LifeCycle {
    case inital
    case willBecomeActive
    case didBecomeActive
    case willResignActive
    case didResignActive
    case willDetach
    case didDetach
}

public protocol MaybeRetrievable {
    func retrieve(_ userInfo: Any?)
}

extension MaybeRetrievable {
    @inlinable
    public func retrieve(_ userInfo: Any?) {}
}

/// Managed scene context for lifecycle and relationship management
open class ManagedSceneContext {
    @usableFromInline
    var next: Scene?
    @usableFromInline
    var previous: Scene?
    @usableFromInline
    var cancellables: Set<AnyCancellable>

    @usableFromInline
    weak var parent: Scene?
    @usableFromInline
    var children: [Scene]
    @usableFromInline
    var current: Scene?

    @usableFromInline
    var lifeCycle: CurrentValueSubject<LifeCycle, Never>
    @usableFromInline
    var isPerformed: Bool

    public init(children: [Scene] = []) {
        self.children = children
        self.lifeCycle = .init(.inital)
        self.cancellables = .init()
        self.isPerformed = false
    }

    @inlinable
    public func collect(_ cancellable: Cancellable) {
        cancellable.store(in: &cancellables)
    }
}

// MARK: - Scene Protocol

/// Protocol for scene management
public protocol Scene: MaybeRetrievable, AnyObject {
    /// An object manages scene relationship and life cycle state
    var managedContext: ManagedSceneContext { get }

    var id: String { get }

    /// Prepare the scene before performing it
    func prepareSelf() async

    func perform(with userInfo: Any?) async

    /**
     Set children, then perform one of them by the given index if index is not nil

     - Parameters:
     - children: An array of scenes
     - index: Optional. Index of the scene in the given array that should be performed first.

     - Throws:
     - Fatal error if the given index is out of range
     */
    func set(children: [Scene], performAtIndex index: Int?, with userInfo: Any?) async

    /// Attach a scene as a child then perform it, it will be included in the children collection.
    func attach(child scene: Scene, with userInfo: Any?) async

    /// Perform the child at the given index with user info
    func performChild(at index: Int, with userInfo: Any?) async

    /// Navigate to new scene
    func `switch`(to scene: Scene, with userInfo: Any?) async

    /// Prepare for the next scene to become active
    func prepare(for scene: Scene) async

    /// Dismiss this scene, release all resources
    /// Once this scene is detached, it cannot be reused.
    func detach(with userInfo: Any?) async

    /// Determine actions the scene should do while detaching
    /// Do not call viewManager's dismiss or goBack
    func onDetach() async

    /// Resolve a dependency by key path and type
    func resolveDependency<T>(for keyPath: String?, type: T.Type) async -> T?
}
