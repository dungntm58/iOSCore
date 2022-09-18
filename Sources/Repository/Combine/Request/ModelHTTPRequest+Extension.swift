//
//  ModelHTTPRequest.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 1/19/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import Combine
import CoreRepository

extension SingleModelHTTPRequest {
    @inlinable
    public func create(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.create(value, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    @inlinable
    public func update(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.update(value, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    @inlinable
    public func delete(_ value: Response.ValueType, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.delete(value, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension ListModelHTTPRequest {
    @inlinable
    public func getList(options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.getList(options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension IdentifiableSingleHTTPRequest {
    @inlinable
    public func get(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.get(id: id, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    @inlinable
    public func delete(id: Response.ValueType.ID, options: RequestOption?) -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(self.delete(id: id, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
