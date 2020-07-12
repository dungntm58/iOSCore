//
//  Scene+Redux.swift
//  CoreBase
//
//  Created by Dung Nguyen on 2/28/20.
//

import CoreRedux

extension Scenable {
    @inlinable
    func config<Store>(with store: Store) where Store: Storable {
        let lifeCycleCancellable = self.lifeCycle
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
                [store] shouldActiveStore in
                shouldActiveStore ? store.activate() : store.deactivate()
            })
        _ = managedContext.collect(lifeCycleCancellable)
    }
}