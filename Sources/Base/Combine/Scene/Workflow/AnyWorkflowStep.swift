//
//  WorkflowStep.swift
//  CoreBase
//
//  Created by Robert on 6/26/20.
//

import Combine

public struct AnyWorkflowStep: WorkflowStepping {
    public typealias WorkflowItem = Any
    public typealias WorkflowStepAction = Any

    private let box: AnyWorkflowStepBox

    var base: Any { box.base }

    @usableFromInline
    init<WS>(workflowStep: WS) where WS: WorkflowStepping {
        if let workflowStep = workflowStep as? AnyWorkflowStep {
            self = workflowStep
        } else {
            box = Box(workflowStep)
        }
    }

    public func perform(action: WorkflowStepAction, with object: Any?) {
        box.perform(action: action, with: object)
    }

    public func produceWorkflowItem() -> AnyPublisher<Any, Never> {
        box.produceWorkflowItem()
    }
}

private protocol AnyWorkflowStepBox {
    var base: Any { get }
    func perform(action: Any, with object: Any?)
    func produceWorkflowItem() -> AnyPublisher<Any, Never>
}

private extension AnyWorkflowStep {
    struct Box<Base>: AnyWorkflowStepBox where Base: WorkflowStepping {
        let _base: Base

        @inlinable
        var base: Any { _base }

        @usableFromInline
        init(_ base: Base) {
            self._base = base
        }

        @inlinable
        func perform(action: Any, with object: Any?) {
            guard let action = action as? Base.WorkflowStepAction else {
                return
            }
            _base.perform(action: action, with: object)
        }

        @inlinable
        func produceWorkflowItem() -> AnyPublisher<Any, Never> {
            _base.produceWorkflowItem().map { $0 }.eraseToAnyPublisher()
        }
    }
}
