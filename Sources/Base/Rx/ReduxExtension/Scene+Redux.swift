//
//  Scene+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import CoreRedux
import CoreBase

extension Activating {
    public func associate(with scene: Scened) {
        let lifeCycleDiposable = scene.lifeCycle
            .map { state -> Bool in
                switch state {
                case .didBecomeActive, .willResignActive, .willDetach:
                    return true
                default:
                    return false
                }
            }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { `self`, shouldActiveStore in
                shouldActiveStore ? self.activate() : self.deactivate()
            })
        scene.managedContext.collect(lifeCycleDiposable)
    }
}
