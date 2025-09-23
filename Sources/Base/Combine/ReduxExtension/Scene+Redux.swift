//
//  Scene+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import CoreRedux
import CoreBase
import CoreMacroProtocols

extension Activating where Self: AnyObject {
    public func associate(with scene: Scene) {
        let lifeCycleCancellable = scene.lifeCycle
            .map { state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            }
            .removeDuplicates()
            .sink(receiveValue: { [weak self] shouldActiveStore in
                shouldActiveStore ? self?.activate() : self?.deactivate()
            })
        scene.managedContext.collect(lifeCycleCancellable)
    }
}
