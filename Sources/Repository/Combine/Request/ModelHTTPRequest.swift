//
//  ModelHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Combine
import FoundationExtInternal

public protocol SingleModelHTTPRequest: HTTPRequest where Response: SingleHTTPResponse {
    func create(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error>
    func update(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error>
    func delete(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error>
}

public protocol ListModelHTTPRequest: HTTPRequest where Response: ListHTTPResponse {
    func getList(options: RequestOption?) -> AnyPublisher<Response, Error>
}

public protocol IdentifiableSingleHTTPRequest: SingleModelHTTPRequest where Response.ValueType: Identifiable {
    func get(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error>
    func delete(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error>
}

extension SingleModelHTTPRequest {
    @inlinable
    public func create(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    @inlinable
    public func update(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }
}

extension IdentifiableSingleHTTPRequest {
    @inlinable
    public func get(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    @inlinable
    public func delete(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }
}
