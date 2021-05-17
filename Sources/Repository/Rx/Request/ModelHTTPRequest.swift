//
//  ModelHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import FoundationExt_R
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

extension SingleModelHTTPRequest {
    @inlinable
    public func create(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    @inlinable
    public func update(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    @inlinable
    public func delete(_ value: Response.ValueType, options: RequestOption?) -> Observable<Response> {
        .empty()
    }
}

extension IdentifiableSingleHTTPRequest {
    @inlinable
    public func get(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response> {
        .empty()
    }

    @inlinable
    public func delete(id: Response.ValueType.ID, options: RequestOption?) -> Observable<Response> {
        .empty()
    }
}
