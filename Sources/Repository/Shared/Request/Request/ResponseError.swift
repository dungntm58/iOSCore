//
//  ResponseError.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/25/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

@frozen
public struct ResponseError: Error {
    public let httpCode: Int
    public let message: String?
    public let code: Int
    public let data: Data?

    public init(httpCode: Int, message: String?, code: Int, data: Data?) {
        self.httpCode = httpCode
        self.message = message
        self.code = code
        self.data = data
    }

    @inlinable
    public var localizedDescription: String { message ?? "" }
}
