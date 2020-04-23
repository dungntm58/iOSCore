//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift

open class ManagedSceneContext {
    var previous: Scenable?
    let disposables: CompositeDisposable

    weak var parent: Scenable?
    var children: [Scenable]
    var current: Scenable?

    var lifeCycle: BehaviorSubject<LifeCycle>
    var isPerformed: Bool

    deinit {
        disposables.dispose()
        lifeCycle.dispose()
    }

    public init(children: [Scenable] = []) {
        self.children = children
        self.lifeCycle = .init(value: .inital)
        self.disposables = .init()
        self.isPerformed = false
    }

    @discardableResult
    public func collect(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        disposables.insert(disposable)
    }
}
