//
//  Storable.swift
//  CoreRedux
//
//  Created by Robert on 8/10/19.
//

import Combine

public protocol Storable: AnyObject, Activating {
    associatedtype State: Stateable

    var currentState: State { get }
    var state: AnyPublisher<State, Never> { get }
    var isActive: Bool { get }
}
