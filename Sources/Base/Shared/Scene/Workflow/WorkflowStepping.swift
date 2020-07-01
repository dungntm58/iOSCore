//
//  WorkflowStepping.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/26/20.
//

import Foundation

public protocol WorkflowStepping: WorkflowItemProducible {
    associatedtype WorkflowStepAction

    func perform(action: WorkflowStepAction, with object: Any?)
}

extension WorkflowStepping {
    public func eraseToAny() -> AnyWorkflowStep { .init(workflowStep: self) }
}
