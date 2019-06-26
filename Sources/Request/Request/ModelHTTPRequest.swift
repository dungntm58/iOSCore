//
//  ModelHTTPRequest.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import CoreCleanSwiftBase

public protocol SingleModelHTTPRequest: HTTPRequest where Response: SingleHTTPResponse {
    func create(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
    func update(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
    func delete(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
}

public protocol ListModelHTTPRequest: HTTPRequest where Response: ListHTTPResponse {
    func getList(options: RequestOption?) -> Observable<Response>
}

public protocol IdentifiableHTTPRequest: SingleModelHTTPRequest where Response.ValueType: Identifiable {
    func get(id: Response.ValueType.IDType, options: RequestOption?) -> Observable<Response>
    func delete(id: Response.ValueType.IDType, options: RequestOption?) -> Observable<Response>
}
