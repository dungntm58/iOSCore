//
//  ListResponse.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

/* Update pagination in the next version
 */

public protocol PaginationResponse {
    var total: Int { get }
    var pageSize: Int { get }
    var after: Any { get }
    var before: Any { get }
}

public extension PaginationResponse {
    var hasAfter: Bool {
        if case Optional<Any>.none = after {
            return false
        } else {
            return true
        }
    }

    var hasBefore: Bool {
        if case Optional<Any>.none = before {
            return false
        } else {
            return true
        }
    }
}

public protocol PaginationRequest: DataFetchOptions {}

public struct ListResponse<T> {
    public let pagination: PaginationResponse?
    public let data: [T]

    public init(data: [T], pagination: PaginationResponse? = nil) {
        self.data = data
        self.pagination = pagination
    }
}
