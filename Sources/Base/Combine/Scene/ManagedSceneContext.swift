//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import Combine

open class ManagedSceneContext {
    @usableFromInline
    var next: Scened?
    @usableFromInline
    var previous: Scened?
    @usableFromInline
    var cancellables: Set<AnyCancellable>

    @usableFromInline
    weak var parent: Scened?
    @usableFromInline
    var children: [Scened]
    @usableFromInline
    var current: Scened?

    @usableFromInline
    var lifeCycle: CurrentValueSubject<LifeCycle, Never>
    @usableFromInline
    var isPerformed: Bool

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    public init(children: [Scened] = []) {
        self.children = children
        self.lifeCycle = .init(.inital)
        self.cancellables = .init()
        self.isPerformed = false
    }

    @inlinable
    public func collect(_ cancellable: Cancellable) {
        cancellable.store(in: &cancellables)
    }
}
