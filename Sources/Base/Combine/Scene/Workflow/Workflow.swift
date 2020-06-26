//
//  Workflow.swift
//  CoreBase
//
//  Created by Robert on 6/26/20.
//

import Combine

public class Workflow  {

    private static var instance: Workflow?

    var step: AnyPublisher<AnyWorkflowStep, Never>
    lazy var cancellables = Set<AnyCancellable>()

    private init<FirstStep>(step: FirstStep) where FirstStep: Launchable & WorkflowStepping {
        self.step = Future { $0(.success(step)) }
            .handleEvents(receiveOutput: { $0.launch() })
            .map { $0.eraseToAny() }
            .eraseToAnyPublisher()
    }

    public static func start<FirstStep>(firstStep: FirstStep) -> Workflow where FirstStep: Launchable & WorkflowStepping {
        let workflow = Workflow(step: firstStep)
        instance = workflow
        return workflow
    }

    public func next<PreviousStep, NextStep>(handler: @escaping (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> AnyPublisher<(PreviousStep.WorkflowStepAction, NextStep), Never>) -> Workflow
        where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping {
        self.step = self.step
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .flatMap ({ item in
                        handler(item as! PreviousStep.WorkflowItem, step.base as! PreviousStep)
                            .handleEvents(receiveOutput: { step.perform(action: $0.0, with: item) })
                    })
            })
            .map { $0.1.eraseToAny() }
            .eraseToAnyPublisher()
        return self
    }

    public func next<PreviousStep, NextStep>(handler: @escaping (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> (PreviousStep.WorkflowStepAction, NextStep)) -> Workflow
        where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping {
        self.step = self.step
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .map ({ item -> (PreviousStep.WorkflowStepAction, NextStep) in
                        let r = handler(item as! PreviousStep.WorkflowItem, step.base as! PreviousStep)
                        step.perform(action: r.0, with: item)
                        return r
                    })
            })
            .map { $0.1.eraseToAny() }
            .eraseToAnyPublisher()
        return self
    }

    public func commit() {
        step.sink(receiveValue: { _ in }).store(in: &cancellables)
    }
}

