//
//  WorkflowScene.swift
//  CoreBase
//
//  Created by Robert on 6/26/20.
//

import Foundation

public enum WorkflowSceneStepAction {
    case switchToNewScene(scene: Scenable)
    case performChild(index: Int)

    case detach
    case detachNTimes(n: Int)
    case detachToSceneType(type: Scenable.Type)
    case detachToScene(scene: Scenable)

    case none
}

extension WorkflowStepping where Self: Scenable, WorkflowStepAction == WorkflowSceneStepAction {
    public func perform(action: WorkflowStepAction) {
        switch action {
        case .switchToNewScene(let scene):
            self.switch(to: scene)
        case .performChild(let index):
            self.performChild(at: index)
        case .detach:
            self.detach()
        case .detachNTimes(let n):
            var current: Scenable? = self
            for _ in 0..<n {
                let previous = current?.previous
                if previous == nil { break }
                current = previous
            }
            current?.detach()
        case .detachToSceneType(let t):
            var current: Scenable? = parent
            var isFound = false
            while current != nil && type(of: parent) != t {
                current = current?.parent
                isFound = true
            }
            guard isFound else { break }
            current?.detach()
        case .detachToScene(let scene):
            var current: Scenable? = parent
            var isFound = false
            while parent === scene {
                current = current?.parent
                isFound = true
            }
            guard isFound else { break }
            current?.detach()
        case .none:
            break
        }
    }
}
