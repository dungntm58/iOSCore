//
//  Scenario.swift
//  CoreBase
//
//  Created by Robert Nguyen on 5/15/19.
//

import Combine

open class ManagedSceneContext {
    var previous: Scenable?
    var cancellables: Set<AnyCancellable>

    weak var parent: Scenable?
    var children: [Scenable]
    var current: Scenable?

    var lifeCycle: CurrentValueSubject<LifeCycle, Never>
    var isPerformed: Bool

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    public init(children: [Scenable] = []) {
        self.children = children
        self.lifeCycle = .init(.inital)
        self.cancellables = .init()
        self.isPerformed = false
    }

    public func insertCancellable(_ cancellable: Cancellable) {
        cancellable.store(in: &cancellables)
    }
}
