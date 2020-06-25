//
//  Workflow.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/24/20.
//

import RxSwift

public class Workflow  {

    private static var instance: Workflow = .init()

    var step: Observable<AnyWorkflowStep>
    lazy var disposeBag = DisposeBag()
    var currentScene: Scenable

    private init() {
        fatalError()
    }

    private init<FirstStep>(step: FirstStep) where FirstStep: Launchable & WorkflowStep {
        self.step = Observable.just(step).do(onNext: { $0.launch() }).map { $0.eraseToAny() }
        self.currentScene = step
    }

    public static func start<FirstStep>(firstStep: FirstStep) -> Workflow where FirstStep: Launchable & WorkflowStep {
        instance = Workflow(step: firstStep)
        return instance
    }

    public func next<WorkflowItem, NextStep>(handler: @escaping (_ previousStepItem: WorkflowItem, _ currentScene: Scenable) -> Observable<(WorkflowStepAction, NextStep)>) -> Workflow where NextStep: WorkflowStep {
        self.step = self.step
            .asObservable()
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .compactMap { $0 as? WorkflowItem }
                    .flatMap { item in handler(item, self.currentScene) }
                    .do(onNext: { [weak self] in self?.currentScene = step.perform(action: $0.0) })
            })
            .map { $0.1.eraseToAny() }
        return self
    }

    public func next<WorkflowItem, NextStep>(handler: @escaping (_ previousStepItem: WorkflowItem, _ currentScene: Scenable) -> (WorkflowStepAction, NextStep)) -> Workflow where NextStep: WorkflowStep {
        self.step = self.step
            .asObservable()
            .flatMap ({ step in
                step.produceWorkflowItem()
                    .compactMap { $0 as? WorkflowItem }
                    .map { item in handler(item, self.currentScene) }
                    .do(onNext: { [weak self] in self?.currentScene = step.perform(action: $0.0) })
            })
            .map { $0.1.eraseToAny() }
        return self
    }

    public func commit() {
        step.subscribe().disposed(by: disposeBag)
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
        .start(firstStep: ExLauchableScene())
        .next(handler: handleLaunchSceneToOtherScene(isLoggedIn:currentScene:))
        .commit()
}

func handleLaunchSceneToOtherScene(isLoggedIn: Bool, currentScene: Scenable) -> (WorkflowStepAction, ExOtherScene) {
    let scene = ExOtherScene()
    if isLoggedIn {
        return (WorkflowStepAction.switchToNewScene(scene: scene), scene)
    } else {
        return (WorkflowStepAction.none, scene)
    }
}
