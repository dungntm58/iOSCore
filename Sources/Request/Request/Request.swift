//
//  Request.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

import RxSwift
import Alamofire

/* Should use an enum struct to conform this protocol
 * Eg: enum Enviroment: RequestEnvironment {}
 */
public protocol RequestEnvironment {
    var config: RequestConfiguration { get }
}

public protocol RequestAPI {
    var cachePolicy: URLRequest.CachePolicy { get }
    var cacheTimeoutInterval: TimeInterval { get }

    var endPoint: String { get }

    var method: HTTPMethod { get }
    var extraHeaders: HTTPHeaders? { get }
    var extraParams: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

public extension RequestAPI {
    var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    var cacheTimeoutInterval: TimeInterval {
        return 0
    }

    var extraParams: Parameters? {
        return nil
    }

    var extraHeaders: HTTPHeaders? {
        return nil
    }

    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
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
