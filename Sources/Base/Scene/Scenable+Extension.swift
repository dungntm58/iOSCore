//
//  Scenable+Extension.swift
//  RxCoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension Scenable {
    func forwardDataWhenDetach() -> Any {
        Optional<Any>.none as Any // Nil of any
    }

    func `switch`(to scene: Scenable) {
        updateLifeCycle(.willResignActive)
        prepare(for: scene)
        scene.previous = self
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
        updateLifeCycle(.didResignActive)
    }

    func attach(child scene: Scenable) {
        if children.contains(where: { scene as AnyObject === $0 as AnyObject }) {
            #if !RELEASE && !PRODUCTION
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
            scene.updateLifeCycle(.willBecomeActive)
            prepare(for: scene)
            scene.parent = self
            scene.perform()
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
            managedContext.insertDisposable(
                lifeCycle.subscribe(onNext: scene.managedContext.lifeCycle.onNext)
            )
        }
    }

    func set(children: [Scenable], performAtIndex index: Int?) {
        guard let index = index else {
            return self.children = children
        }

        let scene = children[index]
        prepare(for: scene)
        self.children = children
        children.forEach {
            scene in
            scene.parent = self
            managedContext.insertDisposable(
                lifeCycle.subscribe(onNext: scene.managedContext.lifeCycle.onNext)
            )
        }
        current = scene
        scene.perform()
        scene.updateLifeCycle(.didBecomeActive)
    }

    func detach() {
        #if !RELEASE && !PRODUCTION
        Swift.print("Detach scene", type(of: self))
        printSceneHierachyDebug()
        #endif
        if previous == nil {
            parent?.detach()
            return
        }

        let previousScene = self.previous
        updateLifeCycle(.willDetach)
        children.removeAll()
        current = nil
        previous = nil
        if let parent = parent, let selfIndex = parent.children.firstIndex(where: { $0 === self }) {
            parent.children.remove(at: selfIndex)
        }
        parent?.current = nil
        if let previousScene = previousScene {
            previousScene.updateLifeCycle(.willBecomeActive)
            previousScene.retrieve?(forwardDataWhenDetach())
            previousScene.updateLifeCycle(.didBecomeActive)
        }
        onDetach()
        updateLifeCycle(.didDetach)
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

    #if !RELEASE && !PRODUCTION
    func printSceneHierachyDebug() {
        Swift.print("------- Scene hierachy -------")
        guard var currentScene = previous ?? parent else { return }
        Swift.print("Scene", type(of: self), "\n    - Parent:", parent == nil ? "nil" : "\(type(of: parent as! Scene as Any))", "\n    - Previous:", previous == nil ? "nil" : "\(type(of: previous as! Scene as Any))")
        while let scene = currentScene.previous ?? currentScene.parent {
            Swift.print("Scene", type(of: currentScene), "\n    - Parent:", currentScene.parent == nil ? "nil" : "\(type(of: currentScene.parent as! Scene as Any))", "\n    - Previous:", currentScene.previous == nil ? "nil" : "\(type(of: currentScene.previous as! Scene as Any))")
            currentScene = scene
        }
        Swift.print("-----------------------------")
    }
    #endif
}

// MARK: - Shortcut
public extension Scenable {
    internal(set) var previous: Scenable? {
        set { managedContext.previous = newValue }
        get { managedContext.previous }
    }

    internal(set) var children: [Scenable] {
        set { managedContext.children = newValue }
        get { managedContext.children }
    }

    internal(set) var parent: Scenable? {
        set { managedContext.parent = newValue }
        get { managedContext.parent }
    }

    internal(set) var isPerformed: Bool {
        set { managedContext.isPerformed = newValue }
        get { managedContext.isPerformed }
    }

    /// The nearest child scene that has been performed
    internal(set) var current: Scenable? {
        set { managedContext.current = newValue }
        get { managedContext.current }
    }
}

// MARK: - Convenience
public extension Scenable {
    /// Return an observable instance that observe life cycle of this scene.
    var lifeCycle: Observable<LifeCycle> {
        managedContext.lifeCycle.asObservable()
    }

    /// Return the current value of life cycle
    func getLifeCycleState() throws -> LifeCycle {
        try managedContext.lifeCycle.value()
    }

    /// The most leaf child scene that has been performed
    var visible: Scenable {
        var currentScene: Scenable = self
        while let scene = currentScene.current {
            currentScene = scene
        }
        return currentScene
    }

    /// The parent or one of its ancestor
    var ancestor: Scenable? {
        guard var currentScene = parent else { return nil }

        while let scene = currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    var root: Scenable? {
        guard var currentScene = previous ?? parent else { return nil }

        while let scene = currentScene.previous ?? currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    var nearestViewable: Viewable? {
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

extension Scenable {
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.onNext(value)
    }
}
