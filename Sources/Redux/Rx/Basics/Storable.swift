//
//  Storable.swift
//  CoreRedux
//
//  Created by Robert on 8/10/19.
//

import RxSwift

public protocol Storable: class, Activating {
    associatedtype State: Stateable

    var currentState: State { get }
    var state: Observable<State> { get }
    var isActive: Bool { get }
}
