//
//  ResponseError.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/25/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public struct ResponseError: Error {
    public let httpCode: Int
    public let message: String
    public let code: Int
    public let data: Data?

    public var localizedDescription: String { message }
}
