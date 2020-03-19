//
//  Observable+Extension.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 5/18/19.
//

import Combine

public extension Publisher where Output: Actionable {
    func of(types: [Output.ActionType]) -> Publishers.Filter<Self> {
        filter { types.contains($0.type) }
    }

    func of(type: Output.ActionType...) -> Publishers.Filter<Self> {
        filter { type.contains($0.type) }
    }
}
