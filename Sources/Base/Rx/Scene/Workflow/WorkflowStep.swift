//
//  WorkflowStep.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public protocol WorkflowItemProducable {
    associatedtype WorkflowItem

    func produceWorkflowItem() -> Observable<WorkflowItem>
}

public protocol WorkflowStepping: WorkflowItemProducable {
    associatedtype WorkflowStepAction

    func perform(action: WorkflowStepAction)
}

extension WorkflowStepping {
    public func eraseToAny() -> AnyWorkflowStep { .init(workflowStep: self) }
}

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

    public func perform(action: WorkflowStepAction) {
        box.perform(action: action)
    }

    public func produceWorkflowItem() -> Observable<Any> {
        box.produceWorkflowItem()
    }
}

private protocol AnyWorkflowStepBox {
    var base: Any { get }
    func perform(action: Any)
    func produceWorkflowItem() -> Observable<Any>
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
        func perform(action: Any) {
            _base.perform(action: action as! Base.WorkflowStepAction)
        }

        @inlinable
        func produceWorkflowItem() -> Observable<Any> {
            _base.produceWorkflowItem().map { $0 }
        }
    }
}
