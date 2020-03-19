//
//  Storable.swift
//  RxCoreRedux
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public protocol Activating {
    func activate()
    func deactivate()
}

public protocol Storable: class, Activating {
    associatedtype State: Statable

    var currentState: State { get }
    var state: Observable<State> { get }
    var isActive: Bool { get }
}
