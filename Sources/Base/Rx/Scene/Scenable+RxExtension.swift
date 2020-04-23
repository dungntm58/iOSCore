//
//  Scenable+Extension.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

import RxSwift

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

    func bindLifeCycle(to scene: Scenable) {
        managedContext.collect(lifeCycle.subscribe(onNext: scene.managedContext.lifeCycle.onNext))
    }
}
