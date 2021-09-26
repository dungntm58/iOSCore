//
//  HTTPResponse.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Foundation
import CoreRepository

/* Common structure of HTTPResponse
 * Meta, pagination, global data might be required
 */

public protocol HTTPResponse {
    associatedtype ValueType

    var errorCode: Int { get }
    var message: String? { get }
    var success: Bool { get }
}

public protocol SingleHTTPResponse: HTTPResponse {
    var result: ValueType? { get }
}

public protocol ListHTTPResponse: HTTPResponse {
    var pagination: Paginated? { get }
    var results: [ValueType]? { get }
}

extension ListDTO {
    public init<Response>(response: Response) where Response: ListHTTPResponse, Response.ValueType == T {
        self.init(data: response.results ?? [], pagination: response.pagination)
    }
}
