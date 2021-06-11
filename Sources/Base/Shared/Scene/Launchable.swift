//
//  Router.swift
//  CoreBase
//
//  Created by Robert Nguyen on 6/5/19.
//

public protocol Launchable where Self: Scened {
    /// Perform the scene as the root
    /// Can be called multiple times
    func launch()
}

extension Launchable {
    @inlinable
    public func launch() {
        perform(with: nil)
        if isPerformed { return }
        updateLifeCycle(.didBecomeActive)
    }
}
