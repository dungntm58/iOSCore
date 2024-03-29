//
//  APNSData.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol APNSEventProtocol {
    // swiftlint:disable type_name
    associatedtype T
    // swiftlint:enable type_name

    var event: String { get }
    var data: T? { get }
    init(event: String, data: T?)
}
