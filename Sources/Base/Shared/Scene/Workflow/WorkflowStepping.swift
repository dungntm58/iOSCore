//
//  WorkflowStepping.swift
//  CoreBase
//
//  Created by Dung Nguyen on 6/26/20.
//

import Foundation

public protocol WorkflowStepping: WorkflowItemProducible {
    associatedtype WorkflowStepAction

    func perform(action: WorkflowStepAction, with userInfo: Any?)
}

extension WorkflowStepping {
    @inlinable
    public func eraseToAny() -> AnyWorkflowStep { .init(workflowStep: self) }
}
