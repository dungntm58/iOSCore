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

// MARK: - Default
public extension PureHTTPRequest {
    var defaultParams: Parameters? { nil }

    var session: Session { .default }
}

// MARK: - Convenience
public extension PureHTTPRequest {
    func makeRequest(api: API, options: RequestOption?) throws -> URLRequestConvertible {
        var headers = defaultHeaders
        if let extraHeaders = api.extraHeaders {
            if let _headers = headers {
                headers = HTTPHeaders(_headers.dictionary + extraHeaders.dictionary)
            } else {
                headers = extraHeaders
            }
        }

        var requestParams = options?.parameters
        if let extraParams = api.extraParams {
            if let _requestParams = requestParams {
                requestParams = _requestParams + extraParams
            } else {
                requestParams = extraParams
            }
        }

        let urlString = "\(environment.config.defaultServerUrl)\(api.endPoint)"

        #if !RELEASE && !PRODUCTION
        Swift.print("URL", urlString)
        Swift.print("Headers", headers ?? [:])
        Swift.print("Params", requestParams ?? [:])
        #endif

        let rawRequest = try URLRequest.init(url: urlString, method: api.method, headers: headers)
        var request = try api.encoding.encode(rawRequest, with: requestParams)
        request.cachePolicy = api.cachePolicy
        request.timeoutInterval = api.cacheTimeoutInterval
        return request
    }
}
