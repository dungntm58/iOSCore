//
//  LifecycleSupport.swift
//  CoreMacros
//
//  Supporting types and utilities for lifecycle management
//  Efficient LifecycleStorage replaces swizzling-based lifecycle observation
//

import Foundation

/// Lifecycle events that can be observed
public enum LifecycleEvent: String, CaseIterable {
    case viewWillAppear
    case viewWillDisappear
    case viewDidAppear
    case viewDidDisappear
    case addChild
}

/// Retention policies for stored properties
public enum RetentionPolicy {
    case strong
    case weak
    case copy
}

// Lifecycle protocols removed - lifecycle management handled by LifecycleStorage

/// Storage for lifecycle event callbacks
public class LifecycleStorage {
    public static let shared = LifecycleStorage()
    private var handlers: [ObjectIdentifier: [LifecycleEvent: [() -> Void]]] = [:]
    private let queue = DispatchQueue(label: "lifecycle.storage", attributes: .concurrent)

    private init() {}

    public func addHandler(_ handler: @escaping () -> Void, for event: LifecycleEvent, target: AnyObject) {
        let id = ObjectIdentifier(target)
        queue.async(flags: .barrier) {
            if self.handlers[id] == nil {
                self.handlers[id] = [:]
            }
            if self.handlers[id]![event] == nil {
                self.handlers[id]![event] = []
            }
            self.handlers[id]![event]!.append(handler)
        }
    }

    public func executeHandlers(for event: LifecycleEvent, target: AnyObject) {
        let id = ObjectIdentifier(target)
        queue.sync {
            self.handlers[id]?[event]?.forEach { $0() }
        }
    }

    public func removeHandlers(for target: AnyObject) {
        let id = ObjectIdentifier(target)
        queue.async(flags: .barrier) {
            self.handlers.removeValue(forKey: id)
        }
    }
}