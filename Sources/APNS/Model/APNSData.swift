//
//  APNSData.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import CoreCleanSwiftBase

public protocol APNSDataProtocol {
    associatedtype T: Decodable

    var event: String { get }
    var data: T? { get }

    init(event: String, data: T?)
}

public struct DefaultAPNSData<T>: APNSDataProtocol where T: Decodable {
    public let event: String
    public let data: T?

    public init(event: String, data: T?) {
        self.event = event
        self.data = data
    }
}
