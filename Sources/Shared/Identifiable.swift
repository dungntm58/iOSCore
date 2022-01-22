//
//  Identifiable.swift
//  Shared
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Foundation

public protocol Identifiable {
    associatedtype ID: Hashable

    var id: ID { get }
}

extension Identifiable where Self: Hashable {
    public var id: Self { self }
}
