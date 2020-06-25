//
//  WorkflowStep.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public enum WorkflowStepAction {
    case switchToNewScene(scene: Scenable)
    case performChild(index: Int)

    case detach
    case detachNTimes(n: Int)
    case detachToSceneType(type: Scenable.Type)
    case detachToScene(scene: Scenable)

    case none
}

public protocol WorkflowStep {
    associatedtype WorkflowItem

    func perform(action: WorkflowStepAction) -> Scenable
    func produceWorkflowItem() -> Observable<WorkflowItem>
}

extension WorkflowStep where Self: Scenable {
    public func perform(action: WorkflowStepAction) -> Scenable {
        switch action {
        case .switchToNewScene(let scene):
            self.switch(to: scene)
            return scene
        case .performChild(let index):
            self.performChild(at: index)
            return children[index]
        case .detach:
            let previous = self.previous
            self.detach()
            return previous ?? self
        case .detachNTimes(let n):
            var current: Scenable? = self
            for _ in 0..<n {
                let previous = current?.previous
                if previous == nil { break }
                current = previous
            }
            let previous = current?.previous
            current?.detach()
            return previous ?? current ?? self
        case .detachToSceneType(let t):
            var current: Scenable? = parent
            var isFound = false
            while current != nil && type(of: parent) != t {
                current = current?.parent
                isFound = true
            }
            guard isFound else { return self }
            let previous = current?.previous
            current?.detach()
            return previous ?? current ?? self
        case .detachToScene(let scene):
            var current: Scenable? = parent
            var isFound = false
            while parent === scene {
                current = current?.parent
                isFound = true
            }
            guard isFound else { return self }
            let previous = current?.previous
            current?.detach()
            return previous ?? current ?? self
        case .none:
            return self
        }
    }
}

extension WorkflowStep {
    func eraseToAny() -> AnyWorkflowStep { .init(workflowStep: self) }
}

struct AnyWorkflowStep: WorkflowStep {
    typealias WorkflowItem = Any

    private let box: AnyWorkflowStepBox

    @inlinable
    var base: Any { box.base }

    @usableFromInline
    init<WS>(workflowStep: WS) where WS: WorkflowStep {
        if let workflowStep = workflowStep as? AnyWorkflowStep {
            self = workflowStep
        } else {
            box = Box(workflowStep)
        }
    }

    @inlinable
    func perform(action: WorkflowStepAction) -> Scenable {
        box.perform(action: action)
    }

    @inlinable
    func produceWorkflowItem() -> Observable<Any> {
        box.produceWorkflowItem()
    }
}

private protocol AnyWorkflowStepBox {
    var base: Any { get }
    func perform(action: WorkflowStepAction) -> Scenable
    func produceWorkflowItem() -> Observable<Any>
}

private extension AnyWorkflowStep {
    struct Box<Base>: AnyWorkflowStepBox where Base: WorkflowStep {
        let _base: Base

        @inlinable
        var base: Any { _base }

        @usableFromInline
        init(_ base: Base) {
            self._base = base
        }

        @inlinable
        func perform(action: WorkflowStepAction) -> Scenable {
            _base.perform(action: action)
        }

        @inlinable
        func produceWorkflowItem() -> Observable<Any> {
            _base.produceWorkflowItem().map { $0 }
        }
    }
}
