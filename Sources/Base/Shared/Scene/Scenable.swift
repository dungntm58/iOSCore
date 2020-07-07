//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

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
    @objc optional func retrieve(_ userInfo: Any?)
}

public protocol Scenable: class, MaybeRetrievable {
    /// An object manages scene relationship and life cycle state
    var managedContext: ManagedSceneContext { get }

    var id: String { get }

    func perform(with userInfo: Any?)

    /**
     Set children, then perform one of them by given index if index is not nil

     - Parameters:
     - children: An array of scenes
     - index: Optional. Index of the scene in the given array that should be performed first.

     - Throws:
     - Fatal error if the given index is out of range
     */
    func set(children: [Scenable], performAtIndex index: Int?, with userInfo: Any?)

    /// Attach a scene as a child then perform it, it will be included in children collection.
    func attach(child scene: Scenable, with userInfo: Any?)

    /// Navigate to new scene
    func `switch`(to scene: Scenable, with userInfo: Any?)
    func prepare(for scene: Scenable)

    /// Dismiss this scene, release all resources
    /// Once this scene is detached, it cannot be reused.
    func detach(with userInfo: Any?)
    func onDetach()
}
