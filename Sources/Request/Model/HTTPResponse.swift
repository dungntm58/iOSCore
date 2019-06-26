//
//  HTTPResponse.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import CoreCleanSwiftBase

/* Common structure of HTTPResponse
 * Meta, pagination, global data might be required
 */

public protocol HTTPResponse: Decodable {
    associatedtype ValueType: Decodable

    var errorCode: Int { get }
    var message: String { get }
    var success: Bool { get }
}

public protocol SingleHTTPResponse: HTTPResponse {
    var result: ValueType? { get }
}

public protocol ListHTTPResponse: HTTPResponse {
    var pagination: (PaginationResponse & Decodable)? { get }
    var results: [ValueType]? { get }
}
