//
//  HTTPRequest.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Alamofire
import RxSwift
import CoreCleanSwiftBase

public protocol HTTPRequest: class, RawHTTPRequest {
    associatedtype Response: HTTPResponse

    var decoder: JSONDecoder { get }
}

public extension HTTPRequest {
    /* Common HTTP request
     * Return an observable of HTTPResponse to keep data stable
     */
    func execute(api: API, options: RequestOption?) -> Observable<Response>{
        return rawExecute(api: api, options: options).map(transform)
    }

    /* Upload request
     * Return an observable of HTTPResponse to keep data stable
     */
    func upload(api: API, options: UploadRequestOption) -> Observable<Response> {
        return rawUpload(api: api, options: options).map(transform)
    }
}

extension HTTPRequest {
    // Transform data to data response
    func transform(_ data: Data) throws -> Response {
        return try Self.transform(to: Response.self, decoder: decoder)(data)
    }
}
