//
//  HTTPResponse.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

/* Common structure of HTTPResponse
 * Meta, pagination, global data might be required
 */

public protocol HTTPResponse {
    associatedtype ValueType

    var errorCode: Int { get }
    var message: String { get }
    var success: Bool { get }
}

public protocol SingleHTTPResponse: HTTPResponse {
    var result: ValueType? { get }
}

public protocol ListHTTPResponse: HTTPResponse {
    var pagination: PaginationDTO? { get }
    var results: [ValueType]? { get }
}

extension ListDTO {
    public init<Response>(response: Response) where Response: ListHTTPResponse, Response.ValueType == T {
        self.data = response.results ?? []
        self.pagination = response.pagination
    }
}
