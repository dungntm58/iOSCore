//
//  ModelHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Combine

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

public extension SingleModelHTTPRequest {
    func create(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    func update(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    func delete(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }
}

public extension IdentifiableSingleHTTPRequest {
    func get(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }

    func delete(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Empty().eraseToAnyPublisher()
    }
}
