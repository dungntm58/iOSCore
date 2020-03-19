//
//  PureHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert on 3/15/19.
//

import Alamofire

public protocol PureHTTPRequest: Request {
    associatedtype API: RequestAPI

    var session: Session { get }

    /// Override this following method if authorization is required
    var defaultHeaders: HTTPHeaders? { get }

    /// Default params is passed in HTTP Request
    var defaultParams: Parameters? { get }

    /// Make request from api, options
    func makeRequest(api: API, options: RequestOption?) throws -> URLRequestConvertible

    /// Validate status codes
    var acceptableStatusCodes: [Int] { get }
}
