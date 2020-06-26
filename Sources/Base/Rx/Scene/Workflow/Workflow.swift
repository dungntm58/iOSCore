//
//  Workflow.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public class Workflow  {

    private static var instance: Workflow?

    var step: Observable<AnyWorkflowStep>
    lazy var disposeBag = DisposeBag()

    private init<FirstStep>(step: FirstStep) where FirstStep: Launchable & WorkflowStepping {
        self.step = Observable.just(step).do(onNext: { $0.launch() }).map { $0.eraseToAny() }
    }

    public static func start<FirstStep>(firstStep: FirstStep) -> Workflow where FirstStep: Launchable & WorkflowStepping {
        let workflow = Workflow(step: firstStep)
        instance = workflow
        return workflow
    }

    public func next<PreviousStep, NextStep>(handler: @escaping (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> Observable<(PreviousStep.WorkflowStepAction, NextStep)>) -> Workflow
        where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping {
        self.step = self.step
            .asObservable()
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .flatMap ({ item in
                        handler(item as! PreviousStep.WorkflowItem, step.base as! PreviousStep)
                            .do(onNext: { step.perform(action: $0.0, with: item) })
                    })
            })
            .map { $0.1.eraseToAny() }
        return self
    }

    public func next<PreviousStep, NextStep>(handler: @escaping (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> (PreviousStep.WorkflowStepAction, NextStep)) -> Workflow
        where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping {
        self.step = self.step
            .asObservable()
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .map ({ item -> (PreviousStep.WorkflowStepAction, NextStep) in
                        let r = handler(item as! PreviousStep.WorkflowItem, step.base as! PreviousStep)
                        step.perform(action: r.0, with: item)
                        return r
                    })
            })
            .map { $0.1.eraseToAny() }
        return self
    }

    public func commit() {
        step.subscribe().disposed(by: disposeBag)
    }
}
