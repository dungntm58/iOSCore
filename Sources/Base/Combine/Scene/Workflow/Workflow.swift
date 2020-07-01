//
//  Workflow.swift
//  CoreBase
//
//  Created by Robert on 6/26/20.
//

import Combine

public protocol WorkflowItemProducible {
    associatedtype WorkflowItem

    func produceWorkflowItem() -> AnyPublisher<WorkflowItem, Never>
}

public typealias WorkflowStepGeneratorObservable<PreviousStep, NextStep> = (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> AnyPublisher<(PreviousStep.WorkflowStepAction, NextStep), Never> where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping
public typealias WorkflowStepGenerator<PreviousStep, NextStep> = (_ previousStepItem: PreviousStep.WorkflowItem, _ previousStep: PreviousStep) -> (PreviousStep.WorkflowStepAction, NextStep) where PreviousStep: WorkflowStepping, NextStep: WorkflowStepping

public func createWorkflow<FirstStep>(from firstStep: FirstStep) -> AnyPublisher<FirstStep, Never> where FirstStep: Launchable & WorkflowStepping {
    Future{ $0(.success(firstStep)) }
        .handleEvents(receiveOutput: { $0.launch() })
        .eraseToAnyPublisher()
}

extension Publisher where Output: WorkflowStepping, Failure == Never {
    public func next<NextStep>(handler: @escaping WorkflowStepGeneratorObservable<Output, NextStep>) -> AnyPublisher<NextStep, Failure> where NextStep: WorkflowStepping {
        flatMap { step in
            step.produceWorkflowItem()
                .flatMap ({ item in
                    handler(item, step).handleEvents(receiveOutput: { step.perform(action: $0.0, with: item) })
                })
        }
        .map { $0.1 }
        .eraseToAnyPublisher()
    }

    public func next<NextStep>(handler: @escaping WorkflowStepGenerator<Output, NextStep>) -> AnyPublisher<NextStep, Failure> where NextStep: WorkflowStepping {
        flatMap { step in
            step.produceWorkflowItem()
                .map ({ item -> (Output.WorkflowStepAction, NextStep) in
                    let r = handler(item, step)
                    step.perform(action: r.0, with: item)
                    return r
                })
        }
        .map { $0.1 }
        .eraseToAnyPublisher()
    }

    public func commitWorkflow<Cancellables>(into cancellables: inout Cancellables) where Cancellables: RangeReplaceableCollection, Cancellables.Element == AnyCancellable {
        sink(receiveValue: { _ in }).store(in: &cancellables)
    }
}
