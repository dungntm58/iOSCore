//
//  Workflow.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public class Workflow {
    static var instance: Workflow = .init()

    var currentStepObservable: Observable<AnyWorkflowStep>
    lazy var disposeBag = DisposeBag()

    private init() {
        self.currentStepObservable = .empty()
    }

    private init(step: AnyWorkflowStep) {
        self.currentStepObservable = .just(step)
    }

    public static func start<L>(with launchable: L) -> Workflow where L: Launchable & WorkflowStep {
        instance = Workflow(step: AnyWorkflowStep(workflowStep: launchable))
        return instance
    }

    public func then<WS>(handler: @escaping (_ item: Any) -> Observable<WS>) -> Workflow where WS: WorkflowStep {
        currentStepObservable = currentStepObservable
            .flatMap { $0.produceWorkflowItem().flatMap(handler) }
            .map { $0.eraseToAny() }
        return self
    }

    public func commit() {
        self.currentStepObservable.subscribe().disposed(by: disposeBag)
    }
}

class ExLauchableScene: Scene, Launchable, WorkflowStep {
    typealias WorkflowItem = Bool

    func produceWorkflowItem() -> Observable<Bool> {
        .just(true)
    }
}

class ExOtherScene: Scene, WorkflowStep {
    typealias WorkflowItem = Int
    
    func produceWorkflowItem() -> Observable<Int> {
        .just(1)
    }
}

func test() {
    Workflow
        .start(with: ExLauchableScene())
    .then(handler: <#T##(Any) -> Observable<WorkflowStep>#>)
}
