//
//  WorkflowStep.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

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

    public func perform(action: WorkflowStepAction, with userInfo: Any?) {
        box.perform(action: action, with: userInfo)
    }

    public func produceWorkflowItem() -> Observable<Any> {
        box.produceWorkflowItem()
    }
}

private protocol AnyWorkflowStepBox {
    var base: Any { get }
    func perform(action: Any, with userInfo: Any?)
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

        // swiftlint:disable force_cast
        @inlinable
        func perform(action: Any, with userInfo: Any?) {
            _base.perform(action: action as! Base.WorkflowStepAction, with: userInfo)
        }
        // swiftlint:enable force_cast

        @inlinable
        func produceWorkflowItem() -> Observable<Any> {
            _base.produceWorkflowItem().map { $0 }
        }
    }
}
