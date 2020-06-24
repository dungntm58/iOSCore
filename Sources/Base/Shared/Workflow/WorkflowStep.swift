//
//  WorkflowStep.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public protocol WorkflowStep {
    associatedtype WorkflowItem

    func produceWorkflowItem() -> Observable<WorkflowItem>
}

extension WorkflowStep {
    func eraseToAny() -> AnyWorkflowStep { .init(workflowStep: self) }
}

struct AnyWorkflowStep: WorkflowStep {
    typealias WorkflowItem = Any

    private let box: AnyWorkflowStepBox

    init<WS>(workflowStep: WS) where WS: WorkflowStep {
        if let workflowStep = workflowStep as? AnyWorkflowStep {
            self = workflowStep
        } else {
            box = Box(workflowStep)
        }
    }

    func produceWorkflowItem() -> Observable<Any> {
        box.produceWorkflowItem()
    }
}

private protocol AnyWorkflowStepBox {
    func produceWorkflowItem() -> Observable<Any>
}

private extension AnyWorkflowStep {
    struct Box<Base>: AnyWorkflowStepBox where Base: WorkflowStep {
        let _base: Base

        init(_ base: Base) {
            self._base = base
        }

        func produceWorkflowItem() -> Observable<Any> {
            _base.produceWorkflowItem().map { $0 }
        }
    }
}
