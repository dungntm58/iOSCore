//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

// MARK: - Convenience
extension Scenable {
    /// Return an observable instance that observe life cycle of this scene.
    @inlinable
    public var lifeCycle: Observable<LifeCycle> {
        managedContext.lifeCycle.asObservable()
    }

    /// Return the current value of life cycle
    @inlinable
    public func getLifeCycleState() throws -> LifeCycle {
        try managedContext.lifeCycle.value()
    }
}

extension Scenable {
    @inlinable
    func updateLifeCycle(_ value: LifeCycle) {
        managedContext.lifeCycle.onNext(value)
    }

    @inlinable
    func bindLifeCycle(to scene: Scenable) {
        managedContext.collect(lifeCycle.subscribe(onNext: scene.managedContext.lifeCycle.onNext))
    }
}
