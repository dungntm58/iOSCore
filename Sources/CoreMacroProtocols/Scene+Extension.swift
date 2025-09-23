//
//  Scene+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Foundation
import Combine
import CoreMacroProtocols

extension Scene {

    @inlinable
    public func set(children: [Scene], performAtIndex index: Int?) async {
        await set(children: children, performAtIndex: index, with: nil)
    }

    @inlinable
    public func set(children: [Scene]) async {
        await set(children: children, performAtIndex: nil, with: nil)
    }

    @inlinable
    public func attach(child scene: Scene) async {
        await attach(child: scene, with: nil)
    }

    @inlinable
    public func `switch`(to scene: Scene) async {
        await `switch`(to: scene, with: nil)
    }

    @inlinable
    public func detach() async {
        await detach(with: nil)
    }

    @inlinable
    public func `switch`(to scene: Scene, with userInfo: Any?) async {
        updateLifeCycle(.willResignActive)
        next = scene
        await prepare(for: scene)
        scene.previous = self
        await scene.prepareSelf()
        await scene.perform(with: userInfo)
        scene.updateLifeCycle(.didBecomeActive)
        updateLifeCycle(.didResignActive)
    }

    @inlinable
    public func attach(child scene: Scene, with userInfo: Any?) async {
        if children.contains(where: { scene as AnyObject === $0 as AnyObject }) {
#if !RELEASE && !PRODUCTION
            Swift.print("This scene has been already attached")
#endif
            scene.updateLifeCycle(.willBecomeActive)
            retrieve(nil)
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
        } else {
            children.append(scene)
            scene.updateLifeCycle(.willBecomeActive)
            await prepare(for: scene)
            scene.parent = self
            await scene.prepareSelf()
            await scene.perform(with: userInfo)
            current = scene
            scene.updateLifeCycle(.didBecomeActive)
            bindLifeCycle(to: scene)
        }
    }

    @inlinable
    public func set(children: [Scene], performAtIndex index: Int?, with userInfo: Any?) async {
        self.children = children
        children.forEach { scene in
            scene.parent = self
            bindLifeCycle(to: scene)
        }
        guard let index = index else { return }
        let scene = children[index]
        await prepare(for: scene)
        current = scene
        await scene.prepareSelf()
        await scene.perform(with: userInfo)
        scene.updateLifeCycle(.didBecomeActive)
    }

    @inlinable
    public func detach(with userInfo: Any?) async {
#if !RELEASE && !PRODUCTION
        Swift.print("Detach scene", type(of: self))
        printSceneHierachyDebug()
#endif
        if previous == nil {
            await parent?.detach(with: userInfo)
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
            previousScene.retrieve(userInfo)
            previousScene.updateLifeCycle(.didBecomeActive)
        }
        await onDetach()
        updateLifeCycle(.didDetach)
    }

    @inlinable
    public func performChild(at index: Int, with userInfo: Any?) async {
        current?.updateLifeCycle(.willResignActive)
        let scene = children[index]
        await prepare(for: scene)
        await scene.prepareSelf()
        await scene.perform(with: userInfo)
        let prevScene = current
        current = scene
        prevScene?.updateLifeCycle(.didResignActive)

        if scene.isPerformed { return }
        scene.isPerformed = true
        scene.updateLifeCycle(.didBecomeActive)
    }

#if !RELEASE && !PRODUCTION
    // swiftlint:disable force_cast
    @inlinable
    func printSceneHierachyDebug() {
        Swift.print("------- Scene hierachy -------")
        guard var currentScene = previous ?? parent else { return }
        Swift.print(
            "Scene", type(of: self),
            "\n    - Parent:", parent == nil ? "nil" : "\(type(of: parent as! Scene as Any))",
            "\n    - Previous:",
            previous == nil ? "nil" : "\(type(of: previous as! Scene as Any))"
        )
        while let scene = currentScene.previous ?? currentScene.parent {
            Swift.print(
                "Scene", type(of: currentScene),
                "\n    - Parent:", currentScene.parent == nil ? "nil" : "\(type(of: currentScene.parent as! Scene as Any))",
                "\n    - Previous:", currentScene.previous == nil ? "nil" : "\(type(of: currentScene.previous as! Scene as Any))"
            )
            currentScene = scene
        }
        Swift.print("-----------------------------")
    }
    // swiftlint:enable force_cast
#endif
}

// MARK: - Convenience
extension Scene {
    /// The most leaf child scene that has been performed
    @inlinable
    public var visible: Scene {
        var currentScene: Scene = self
        while let scene = currentScene.current {
            currentScene = scene
        }
        return currentScene
    }

    /// The parent or one of its ancestor
    @inlinable
    public var ancestor: Scene? {
        guard var currentScene = parent else { return nil }

        while let scene = currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    @inlinable
    public var root: Scene? {
        guard var currentScene = previous ?? parent else { return nil }

        while let scene = currentScene.previous ?? currentScene.parent {
            currentScene = scene
        }
        return currentScene
    }

    @inlinable
    @MainActor
    public var presentedViewManager: ViewManagable? {
        guard var currentScene = previous ?? parent else { return nil }
        if let viewManager = (currentScene as? (any HasViewManagable))?.anyViewManager {
            return viewManager
        }
        while let scene = currentScene.previous ?? currentScene.parent {
            if let viewManager = (currentScene as? (any HasViewManagable))?.anyViewManager {
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
        case .some(let obj as Flattenable): return obj.flattened()
        case .some(let obj): return obj
        case .none: return nil
        }
    }
}

extension Scene {
    /// Return an observable instance that observe life cycle of this scene.
    @inlinable
    public var lifeCycle: AnyPublisher<LifeCycle, Never> {
        managedContext.lifeCycle.eraseToAnyPublisher()
    }

    /// Return the current value of life cycle
    @inlinable
    public func getLifeCycleState() -> LifeCycle {
        managedContext.lifeCycle.value
    }

    @inlinable
    public func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.send(value)
    }
}

extension Scene {
    @inlinable
    func bindLifeCycle(to scene: Scene) {
        managedContext.collect(lifeCycle.sink(receiveValue: scene.managedContext.lifeCycle.send))
    }
}

// MARK: - Shortcut
extension Scene {
    @inlinable
    internal(set) public var next: Scene? {
        get { managedContext.next }
        set { managedContext.next = newValue }
    }

    @inlinable
    internal(set) public var previous: Scene? {
        get { managedContext.previous }
        set { managedContext.previous = newValue }
    }

    @inlinable
    internal(set) public var children: [Scene] {
        get { managedContext.children }
        set { managedContext.children = newValue }
    }

    @inlinable
    internal(set) public var parent: Scene? {
        get { managedContext.parent }
        set { managedContext.parent = newValue }
    }

    @inlinable
    internal(set) public var isPerformed: Bool {
        get { managedContext.isPerformed }
        set { managedContext.isPerformed = newValue }
    }

    /// The nearest child scene that has been performed
    @inlinable
    internal(set) public var current: Scene? {
        get { managedContext.current }
        set { managedContext.current = newValue }
    }
}
