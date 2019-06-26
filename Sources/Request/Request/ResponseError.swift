//
//  ResponseError.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/25/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public struct ResponseError: Error {
    public let message: String
    public let code: Int
    public let data: Data?

    public init(code: Int, message: String, data: Data? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }

    public var localizedDescription: String {
        return message
    }
}
