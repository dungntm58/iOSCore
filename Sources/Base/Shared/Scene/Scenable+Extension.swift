//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Combine

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
