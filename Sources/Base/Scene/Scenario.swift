//
//  Scenario.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift

public enum LifeCycle {
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

public protocol Scene: class, MaybeRetrievable {
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
    func set(children: [Scene], performAtIndex index: Int?)

    /// Attach a scene as a child then perform it, it will be included in children collection.
    func attach(child scene: Scene)

    /// Navigate to new scene
    func navigate(to scene: Scene)
    func prepare(for scene: Scene)

    /// Dismiss this scene, release all resources
    /// Once this scene is detached, it will be unable to reuse.
    func detach()
    func dataWhenDetach() -> Any
    func onDetach()
}

// Default
public extension Scene {
    func prepare(for scene: Scene) {}
    func dataWhenDetach() -> Any {
        return Optional<Any>.none as Any
    }

    func navigate(to scene: Scene) {
        updateLifeCycle(.willResignActive)
        prepare(for: scene)
        scene.previous = self
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
        updateLifeCycle(.didResignActive)
    }

    func attach(child scene: Scene) {
        if children.contains(where: { scene as AnyObject === $0 as AnyObject }) {
            #if DEBUG
            Swift.print("This scene has been already attached")
            #endif
            if let retrieve = scene.retrieve {
                scene.updateLifeCycle(.willBecomeActive)
                retrieve(Optional<Any>.none as Any)
                current = scene
                scene.updateLifeCycle(.didBecomeActive)
            } else {
                current = scene
            }
        } else {
            children.append(scene)
            prepare(for: scene)
            scene.parent = self
            scene.perform()
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
            lifeCycle
                .bind(to: scene.managedContext.lifeCycle)
                .disposed(by: scene.managedContext.disposeBag)
        }
    }

    func set(children: [Scene], performAtIndex index: Int?) {
        guard let index = index else {
            self.children = children
            return
        }

        let scene = children[index]
        prepare(for: scene)
        self.children = children
        children.forEach {
            scene in
            scene.parent = self
            lifeCycle
                .bind(to: scene.managedContext.lifeCycle)
                .disposed(by: scene.managedContext.disposeBag)
        }
        current = scene
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
    }

    func detach() {
        if previous == nil {
            parent?.detach()
            return
        }
        let previousScene = self.previous

        updateLifeCycle(.willDetach)
        children.removeAll()
        current = nil
        previous = nil
        parent?.children.remove(element: self)
        parent?.current = nil
        if let retrieve = previousScene?.retrieve {
            previousScene?.updateLifeCycle(.willBecomeActive)
            retrieve(dataWhenDetach())
            previousScene?.updateLifeCycle(.didBecomeActive)
        }
        onDetach()
        updateLifeCycle(.didDetach)
        managedContext.lifeCycle.onCompleted()
    }
}

// Shortcut
public extension Scene {
    internal(set) var previous: Scene? {
        set { managedContext.previous = newValue }
        get { return managedContext.previous }
    }

    internal(set) var children: [Scene] {
        set { managedContext.children = newValue }
        get { return managedContext.children }
    }

    internal(set) var parent: Scene? {
        set { managedContext.parent = newValue }
        get { return managedContext.parent }
    }

    internal(set) var isPerformed: Bool {
        set { managedContext.isPerformed = newValue }
        get { return managedContext.isPerformed }
    }

    /// The nearest child scene that has been performed
    internal(set) var current: Scene? {
        set { managedContext.current = newValue }
        get { return managedContext.current }
    }
}

// Convenience
public extension Scene {
    /// Return an observable instance that observe life cycle of this scene.
    var lifeCycle: Observable<LifeCycle> {
        return managedContext.lifeCycle.asObservable()
    }

    /// Return the current value of life cycle
    func getLifeCycleState() throws -> LifeCycle {
        return try managedContext.lifeCycle.value()
    }

    /// The most leaf child scene that has been performed
    var visible: Scene {
        var currentScene: Scene = self
        while let scene = currentScene.current {
            currentScene = scene
        }
        return currentScene
    }

    /// The parent or one of its ancestor
    var ancestor: Scene? {
        guard var currentScene = parent else { return nil }

        while let scene = currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    var root: Scene? {
        guard var currentScene = previous ?? parent else { return nil }

        while let scene = currentScene.previous ?? currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    func performChild(at index: Int) {
        current?.updateLifeCycle(.willResignActive)
        let scene = children[index]
        prepare(for: scene)
        scene.perform()
        let prevScene = current
        current = scene
        prevScene?.updateLifeCycle(.didResignActive)

        if scene.isPerformed { return }
        scene.isPerformed = true
        scene.updateLifeCycle(.didBecomeActive)
    }

    var nearestViewableScene: Viewable? {
        guard var currentScene = previous ?? parent else { return nil }
        if let viewable = currentScene as? Viewable {
            return viewable
        }

        while let scene = currentScene.previous ?? currentScene.parent {
            if let viewable = currentScene as? Viewable {
                return viewable
            }
            currentScene = scene
        }
        return nil
    }
}

extension Scene {
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.onNext(value)
    }
}

public class ManagedSceneContext {
    fileprivate var previous: Scene?
    fileprivate lazy var disposeBag = DisposeBag()

    fileprivate weak var parent: Scene?
    fileprivate var children: [Scene]
    fileprivate var current: Scene?

    var lifeCycle: BehaviorSubject<LifeCycle>
    var isPerformed: Bool

    public init(children: [Scene] = []) {
        self.children = children
        self.lifeCycle = BehaviorSubject<LifeCycle>(value: .willBecomeActive)
        self.isPerformed = false
    }
}
