//
//  Model.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol Expirable {
    var ttl: TimeInterval { get }
    var localUpdatedDate: Date { get }
}

public extension Expirable {
    var expiryDate: Date? { ttl > 0 ? localUpdatedDate.addingTimeInterval(ttl) : nil }

    var isValid: Bool { expiryDate == nil || expiryDate! <= Date() }
}
