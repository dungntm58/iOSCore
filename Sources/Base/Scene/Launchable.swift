//
//  Router.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 6/5/19.
//

public protocol Launchable {
    /// Perform the scene as the root
    /// Can be called multiple times
    func launch()
}

public extension Launchable where Self: Scenable {
    func launch() {
        perform()
        if isPerformed { return }
        updateLifeCycle(.didBecomeActive)
    }
}
