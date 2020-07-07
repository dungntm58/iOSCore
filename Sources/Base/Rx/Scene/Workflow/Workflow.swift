//
//  Workflow.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public protocol WorkflowItemProducible {
    associatedtype WorkflowItem

    func produceWorkflowItem() -> Observable<WorkflowItem>
}

public typealias WorkflowStepGeneratorObservable<PreviousStep, NextStep> = (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> Observable<(PreviousStep.WorkflowStepAction, NextStep)> where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping
public typealias WorkflowStepGenerator<PreviousStep, NextStep> = (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> (PreviousStep.WorkflowStepAction, NextStep) where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping

@inlinable
public func createWorkflow<FirstStep>(from firstStep: FirstStep) -> Observable<FirstStep> where FirstStep: Launchable & WorkflowStepping {
    Observable
        .just(firstStep)
        .do(onNext: { $0.launch() })
}

extension Observable where Element: WorkflowStepping {
    @inlinable
    public func next<NextStep>(handler: @escaping WorkflowStepGeneratorObservable<Element, NextStep>) -> Observable<NextStep> where NextStep: WorkflowStepping {
        flatMap { step in
            step.produceWorkflowItem()
                .flatMap ({ item in
                    handler(item, step).do(onNext: { step.perform(action: $0.0, with: item) })
                })
                
        }
        .map { $0.1 }
    }

    @inlinable
    public func next<NextStep>(handler: @escaping WorkflowStepGenerator<Element, NextStep>) -> Observable<NextStep> where NextStep: WorkflowStepping {
        flatMap { step in
            step.produceWorkflowItem()
                .map ({ item -> (Element.WorkflowStepAction, NextStep) in
                    let r = handler(item, step)
                    step.perform(action: r.0, with: item)
                    return r
                })
        }
        .map { $0.1 }
    }

    @inlinable
    public func commitWorkflow(into disposeBag: DisposeBag) {
        subscribe().disposed(by: disposeBag)
    }
}
