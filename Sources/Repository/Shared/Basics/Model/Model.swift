//
//  Model.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Foundation

public protocol Expirable {
    var ttl: TimeInterval { get }
    var localUpdatedDate: Date { get }
}

extension Expirable {
    @inlinable
    public var expiryDate: Date? { ttl > 0 ? localUpdatedDate.addingTimeInterval(ttl) : nil }

    @inlinable
    public var isValid: Bool { expiryDate == nil || expiryDate! <= Date() }
}
