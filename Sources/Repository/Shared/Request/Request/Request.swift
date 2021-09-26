//
//  Request.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import Foundation
import Alamofire

/**
 * Should use an enum struct to conform this protocol
 * Eg: enum Enviroment: RequestEnvironment {}
 */
public protocol RequestEnvironment {
    var config: RequestConfiguration { get }
}

public protocol Request {
    var environment: RequestEnvironment { get }
}

public protocol RequestConfiguration {
    var baseURL: URL { get }
    var versions: [String] { get }
}

extension RequestConfiguration {
    @inlinable
    public var defaultServerURL: URL {
        if let version = self.versions.last {
            return baseURL.appendingPathComponent(version)
        }
        return baseURL
    }

    @inlinable
    public var versions: [String] { [] }

    /**
     * Get the last server url
     */
    @inlinable
    public func urlOf(version: String) -> URL {
        if versions.contains(version) {
            return baseURL.appendingPathComponent(version)
        }
        return baseURL
    }
}
