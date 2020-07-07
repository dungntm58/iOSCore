//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Combine

// MARK: - Convenience
public extension Scenable {
    /// Return an observable instance that observe life cycle of this scene.
    @inlinable
    var lifeCycle: AnyPublisher<LifeCycle, Never> {
        managedContext.lifeCycle.eraseToAnyPublisher()
    }

    /// Return the current value of life cycle
    @inlinable
    func getLifeCycleState() -> LifeCycle {
        managedContext.lifeCycle.value
    }
}

extension Scenable {
    @inlinable
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.send(value)
    }

    @inlinable
    func bindLifeCycle(to scene: Scenable) {
        managedContext.collect(lifeCycle.sink(receiveValue: scene.managedContext.lifeCycle.send))
    }
}
