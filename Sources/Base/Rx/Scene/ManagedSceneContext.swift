//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift

open class ManagedSceneContext {
    @usableFromInline
    var previous: Scenable?
    @usableFromInline
    let disposables: CompositeDisposable

    @usableFromInline
    weak var parent: Scenable?
    @usableFromInline
    var children: [Scenable]
    @usableFromInline
    var current: Scenable?

    @usableFromInline
    var lifeCycle: BehaviorSubject<LifeCycle>
    @usableFromInline
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
    @inlinable
    public func collect(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        disposables.insert(disposable)
    }
}
