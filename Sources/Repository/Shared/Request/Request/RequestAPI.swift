//
//  RequestAPI.swift
//  CoreRequest
//
//  Created by Robert on 8/10/19.
//

import Foundation
import Alamofire

public protocol RequestAPI {
    var cachePolicy: URLRequest.CachePolicy { get }
    var cacheTimeoutInterval: TimeInterval { get }

    var endPoint: String { get }

    var method: HTTPMethod { get }
    var extraHeaders: HTTPHeaders? { get }
    var extraParams: Parameters? { get }
    var encoding: ParameterEncoding { get }

    var acceptableStatusCodes: [Int] { get }
}

extension RequestAPI {
    @inlinable
    public var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    @inlinable
    public var cacheTimeoutInterval: TimeInterval { 0 }
    @inlinable
    public var extraParams: Parameters? { nil }
    @inlinable
    public var extraHeaders: HTTPHeaders? { nil }
    @inlinable
    public var encoding: ParameterEncoding { URLEncoding.default }
}
