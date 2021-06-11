//
//  Scened+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import Combine

// MARK: - Convenience
extension Scened {
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
}

extension Scened {
    @inlinable
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.send(value)
    }

    @inlinable
    func bindLifeCycle(to scene: Scened) {
        managedContext.collect(lifeCycle.sink(receiveValue: scene.managedContext.lifeCycle.send))
    }
}
