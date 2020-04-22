//
//  ModelHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift

public protocol SingleModelHTTPRequest: HTTPRequest where Response: SingleHTTPResponse {
    func create(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
    func update(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
    func delete(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response>
}

public protocol ListModelHTTPRequest: HTTPRequest where Response: ListHTTPResponse {
    func getList(options: RequestOption?) -> Observable<Response>
}

public protocol IdentifiableSingleHTTPRequest: SingleModelHTTPRequest where Response.ValueType: Identifiable {
    func get(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response>
    func delete(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response>
}

public extension SingleModelHTTPRequest {
    func create(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    func update(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    func delete(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }
}

public extension IdentifiableSingleHTTPRequest {
    func get(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    func delete(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response> {
        .empty()
    }
}
