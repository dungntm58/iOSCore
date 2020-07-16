//
//  Scene+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import CoreRedux

extension SceneAssociated where Self: Activating {

    @inlinable
    public func associate(with scene: Scenable) {
        let lifeCycleCancellable = scene.lifeCycle
            .map ({
                state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            })
            .removeDuplicates()
            .sink(receiveValue: {
                [weak self] shouldActiveStore in
                shouldActiveStore ? self?.activate() : self?.deactivate()
            })
        scene.managedContext.collect(lifeCycleCancellable)
    }
}
