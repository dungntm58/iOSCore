//
//  Scenario.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import Combine

public enum LifeCycle {
    case inital
    case willBecomeActive
    case didBecomeActive
    case willResignActive
    case didResignActive
    case willDetach
    case didDetach
}

@objc public protocol MaybeRetrievable {
    @objc optional func retrieve(_ data: Any)
}

public protocol Scenable: class, MaybeRetrievable {
    /// An object manages scene relationship and life cycle state
    var managedContext: ManagedSceneContext { get }

    func perform()

    /**
     Set children, then perform one of them by given index if index is not nil

     - Parameters:
     - children: An array of scenes
     - index: Optional. Index of the scene in the given array that should be performed first.

     - Throws:
     - Fatal error if the given index is out of range
     */
    func set(children: [Scenable], performAtIndex index: Int?)

    /// Attach a scene as a child then perform it, it will be included in children collection.
    func attach(child scene: Scenable)

    /// Navigate to new scene
    func `switch`(to scene: Scenable)
    func prepare(for scene: Scenable)

    /// Dismiss this scene, release all resources
    /// Once this scene is detached, it cannot be reused.
    func detach()
    func forwardDataWhenDetach() -> Any
    func onDetach()
}

open class ManagedSceneContext {
    var previous: Scenable?
    let cancellable: AnyCancellable

    weak var parent: Scenable?
    var children: [Scenable]
    var current: Scenable?

    var lifeCycle: CurrentValueSubject<LifeCycle, Never>
    var isPerformed: Bool

    deinit {
        cancellable.cancel()
    }

    public init(children: [Scenable] = []) {
        self.children = children
        self.lifeCycle = .init(.inital)
        self.cancellable = .init({})
        self.isPerformed = false
    }

    public func insertCancellable(_ cancellable: Cancellable) {
        
    }
}
