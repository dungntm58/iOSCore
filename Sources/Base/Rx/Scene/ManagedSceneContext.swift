//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import RxSwift

open class ManagedSceneContext {
    @usableFromInline
    var next: Scened?
    @usableFromInline
    weak var previous: Scened?
    @usableFromInline
    let disposables: CompositeDisposable

    @usableFromInline
    weak var parent: Scened?
    @usableFromInline
    var children: [Scened]
    @usableFromInline
    var current: Scened?

    @usableFromInline
    var lifeCycle: BehaviorSubject<LifeCycle>
    @usableFromInline
    var isPerformed: Bool

    deinit {
        disposables.dispose()
        lifeCycle.dispose()
    }

    public init(children: [Scened] = []) {
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
