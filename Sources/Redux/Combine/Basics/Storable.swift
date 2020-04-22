//
//  Storable.swift
//  CoreRedux
//
//  Created by Robert on 8/10/19.
//

import Combine

public protocol Storable: class, Activating {
    associatedtype State: Statable

    var currentState: State { get }
    var state: AnyPublisher<State, Never> { get }
    var isActive: Bool { get }
}
