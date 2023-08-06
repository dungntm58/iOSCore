//
//  WorkflowScene.swift
//  CoreBase
//
//  Created by Robert on 6/26/20.
//

import Foundation

@frozen
public enum WorkflowSceneStepAction {
    case switchToNewScene(scene: Scened)
    case performChild(index: Int)

    case detach
    // swiftlint:disable identifier_name
    case detachNTimes(n: Int)
    // swiftlint:enable identifier_name
    case detachToSceneType(type: Scened.Type)
    case detachToScene(scene: Scened)

    case none
}

public protocol WorkflowSceneStepping: WorkflowStepping where WorkflowStepAction == WorkflowSceneStepAction {}

extension WorkflowStepping where Self: Scened, WorkflowStepAction == WorkflowSceneStepAction {
    // swiftlint:disable cyclomatic_complexity
    @inlinable
    public func perform(action: WorkflowStepAction, with userInfo: Any?) {
        switch action {
        case .switchToNewScene(let scene):
            `switch`(to: scene, with: userInfo)
        case .performChild(let index):
            performChild(at: index, with: userInfo)
        case .detach:
            detach(with: userInfo)
        // swiftlint:disable identifier_name
        case .detachNTimes(let n):
            var current: Scened? = self
            for _ in 0..<n {
                let previous = current?.previous
                if previous == nil { break }
                current = previous
            }
            current?.detach(with: userInfo)
        case .detachToSceneType(let t):
            var current: Scened? = parent
            var isFound = false
            while current != nil && type(of: parent) != t {
                current = current?.parent
                isFound = true
            }
            guard isFound else { break }
            current?.detach(with: userInfo)
        // swiftlint:enable identifier_name
        case .detachToScene(let scene):
            var current: Scened? = parent
            var isFound = false
            while parent === scene {
                current = current?.parent
                isFound = true
            }
            guard isFound else { break }
            current?.detach(with: userInfo)
        case .none:
            break
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
