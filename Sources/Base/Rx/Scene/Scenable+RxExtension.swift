//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public extension Scenable {
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
}

extension Scenable {
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.onNext(value)
    }
}
