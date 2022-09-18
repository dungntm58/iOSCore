//
//  ModelHTTPRequest.swift
//  iOSCore
//
//  Created by Robert on 18/09/2022.
//

import Foundation
import CoreRepository

public protocol SingleModelHTTPRequest: HTTPRequest where Response: SingleHTTPResponse {
    func create(_ value: Response.ValueType, options: RequestOption?) async throws -> Response
    func update(_ value: Response.ValueType, options: RequestOption?) async throws -> Response
    func delete(_ value: Response.ValueType, options: RequestOption?) async throws -> Response
}

public protocol ListModelHTTPRequest: HTTPRequest where Response: ListHTTPResponse {
    func getList(options: RequestOption?) async throws -> Response
}

public protocol IdentifiableSingleHTTPRequest: SingleModelHTTPRequest where Response.ValueType: Identifiable {
    func get(id: Response.ValueType.ID, options: RequestOption?) async throws -> Response
    func delete(id: Response.ValueType.ID, options: RequestOption?) async throws -> Response
}
