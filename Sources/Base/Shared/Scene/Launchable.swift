//
//  Router.swift
//  CoreBase
//
//  Created by Robert Nguyen on 6/5/19.
//

import CoreMacroProtocols

public protocol Launchable where Self: Scene {
    /// Perform the scene as the root
    /// Can be called multiple times
    @MainActor
    func launch() async
}

extension Launchable {
    @inlinable
    public func launch() async {
        await prepareSelf()
        await perform(with: nil)
        if isPerformed { return }
        updateLifeCycle(.didBecomeActive)
    }
}
