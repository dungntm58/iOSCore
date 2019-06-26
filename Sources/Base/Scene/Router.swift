//
//  Router.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 6/5/19.
//

public protocol Lauchable {
    func launch()
}

public extension Lauchable where Self: Scene {
    /// Perform the scene as the root
    /// Can be called multiple times
    func launch() {
        if isPerformed {
            return
        }
        perform()
        updateLifeCycle(.didBecomeActive)
    }
}
