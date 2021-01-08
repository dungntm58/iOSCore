//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Foundation

extension Scenable {

    @inlinable
    public func set(children: [Scenable], performAtIndex index: Int?) {
        set(children: children, performAtIndex: index, with: nil)
    }

    @inlinable
    public func set(children: [Scenable]) {
        set(children: children, performAtIndex: nil, with: nil)
    }

    @inlinable
    public func attach(child scene: Scenable) {
        attach(child: scene, with: nil)
    }

    @inlinable
    public func `switch`(to scene: Scenable) {
        `switch`(to: scene, with: nil)
    }

    @inlinable
    public func detach() {
        detach(with: nil)
    }

    @inlinable
    public func `switch`(to scene: Scenable, with userInfo: Any?) {
        updateLifeCycle(.willResignActive)
        next = scene
        prepare(for: scene)
        scene.previous = self
        scene.perform(with: userInfo)
        scene.updateLifeCycle(.didBecomeActive)
        updateLifeCycle(.didResignActive)
    }

    @inlinable
    public func attach(child scene: Scenable, with userInfo: Any?) {
        if children.contains(where: { scene as AnyObject === $0 as AnyObject }) {
            #if !RELEASE && !PRODUCTION
            Swift.print("This scene has been already attached")
            #endif
            if let retrieve = scene.retrieve {
                scene.updateLifeCycle(.willBecomeActive)
                retrieve(nil)
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
            scene.perform(with: userInfo)
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
            bindLifeCycle(to: scene)
        }
    }

    @inlinable
    public func set(children: [Scenable], performAtIndex index: Int?, with userInfo: Any?) {
        self.children = children
        children.forEach {
            scene in
            scene.parent = self
            bindLifeCycle(to: scene)
        }
        guard let index = index else { return }
        let scene = children[index]
        prepare(for: scene)
        current = scene
        scene.perform(with: userInfo)
        scene.updateLifeCycle(.didBecomeActive)
    }

    @inlinable
    public func detach(with userInfo: Any?) {
        #if !RELEASE && !PRODUCTION
        Swift.print("Detach scene", type(of: self))
        printSceneHierachyDebug()
        #endif
        if previous == nil {
            parent?.detach(with: userInfo)
            return
        }

        let previousScene = self.previous
        updateLifeCycle(.willDetach)
        children.removeAll()
        current = nil
        previous?.next = nil
        previous = nil
        if let parent = parent, let selfIndex = parent.children.firstIndex(where: { $0 === self }) {
            parent.children.remove(at: selfIndex)
        }
        parent?.current = nil
        if let previousScene = previousScene {
            previousScene.updateLifeCycle(.willBecomeActive)
            previousScene.retrieve?(userInfo)
            previousScene.updateLifeCycle(.didBecomeActive)
        }
        onDetach()
        updateLifeCycle(.didDetach)
    }

    @inlinable
    public func performChild(at index: Int, with userInfo: Any?) {
        current?.updateLifeCycle(.willResignActive)
        let scene = children[index]
        prepare(for: scene)
        scene.perform(with: userInfo)
        let prevScene = current
        current = scene
        prevScene?.updateLifeCycle(.didResignActive)

        if scene.isPerformed { return }
        scene.isPerformed = true
        scene.updateLifeCycle(.didBecomeActive)
    }

    #if !RELEASE && !PRODUCTION
    @inlinable
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
extension Scenable {
    @inlinable
    internal(set) public var next: Scenable? {
        set { managedContext.next = newValue }
        get { managedContext.next }
    }

    @inlinable
    internal(set) public var previous: Scenable? {
        set { managedContext.previous = newValue }
        get { managedContext.previous }
    }

    @inlinable
    internal(set) public var children: [Scenable] {
        set { managedContext.children = newValue }
        get { managedContext.children }
    }

    @inlinable
    internal(set) public var parent: Scenable? {
        set { managedContext.parent = newValue }
        get { managedContext.parent }
    }

    @inlinable
    internal(set) public var isPerformed: Bool {
        set { managedContext.isPerformed = newValue }
        get { managedContext.isPerformed }
    }

    /// The nearest child scene that has been performed
    @inlinable
    internal(set) public var current: Scenable? {
        set { managedContext.current = newValue }
        get { managedContext.current }
    }
}

// MARK: - Convenience
extension Scenable {

    @inlinable
    public var anyViewManager: ViewManagable? {
        Mirror(reflecting: self)
            .children
            .compactMap({
                if let viewManager = $0.value as? ViewManagable {
                    return viewManager
                }
                let dependency = Mirror(reflecting: $0.value)
                    .children
                    .first { $0.label == "dependency" }?
                    .value
                return dependency.flattened() as? ViewManagable
            })
            .first
    }

    /// The most leaf child scene that has been performed
    @inlinable
    public var visible: Scenable {
        var currentScene: Scenable = self
        while let scene = currentScene.current {
            currentScene = scene
        }
        return currentScene
    }

    /// The parent or one of its ancestor
    @inlinable
    public var ancestor: Scenable? {
        guard var currentScene = parent else { return nil }

        while let scene = currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    @inlinable
    public var root: Scenable? {
        guard var currentScene = previous ?? parent else { return nil }

        while let scene = currentScene.previous ?? currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    @inlinable
    public var presentedViewManager: ViewManagable? {
        guard var currentScene = previous ?? parent else { return nil }
        if let viewManager = currentScene.anyViewManager {
            return viewManager
        }
        while let scene = currentScene.previous ?? currentScene.parent {
            if let viewManager = currentScene.anyViewManager {
                return viewManager
            }
            currentScene = scene
        }
        return nil
    }
}

protocol Flattenable {
    func flattened() -> Any?
}

extension Optional: Flattenable {
    @usableFromInline
    func flattened() -> Any? {
        switch self {
        case .some(let x as Flattenable): return x.flattened()
        case .some(let x): return x
        case .none: return nil
        }
    }
}
