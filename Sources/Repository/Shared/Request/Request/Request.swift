//
//  Request.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

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
    var baseUrl: String { get }
    var versions: [String] { get }
}

public extension RequestConfiguration {
    var defaultServerUrl: String {
        if let version = self.versions.last {
            return "\(baseUrl)/\(version)"
        }
        return baseUrl
    }

    /**
     * Get the last server url
     */
    func urlOf(version: String) -> String {
        if versions.contains(version) {
            return "\(baseUrl)/\(version)"
        }
        return baseUrl
    }
}
