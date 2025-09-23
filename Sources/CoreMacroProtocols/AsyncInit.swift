//
//  AsyncInit.swift
//  CoreBase
//
//  An value wrapper for async initialization in actors
//

import Foundation

public actor AsyncInit<Value> {
    private var _value: Value?
    private let initializationTask: Task<Value, Never>

    public init(initializer: @escaping () async -> Value) {
        self.initializationTask = Task {
            await initializer()
        }
    }

    public var value: Value {
        get async {
            if let value = await _value {
                return value
            }
            let value = await initializationTask.value
            _value = value
            return value
        }
    }
}
