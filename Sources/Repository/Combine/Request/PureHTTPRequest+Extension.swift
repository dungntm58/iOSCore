//
//  RawHTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 5/13/19.
//

import Foundation
import Alamofire
import Combine
import CoreRepository

// MARK: - Convenience
extension PureHTTPRequest {
    @inlinable
    public func pureExecute(api: API, options: RequestOption?) -> AnyPublisher<AFDataResponse<Data>, Error> {
        Future<AFDataResponse<Data>, Error> { promise in
            Task {
                do {
                    try await promise(.success(pureExecute(api: api, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    @inlinable
    public func pureUpload(api: API, options: UploadRequestOption) -> AnyPublisher<AFDataResponse<Data>, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(pureUpload(api: api, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    // swiftlint:enable function_body_length cyclomatic_complexity

    /// Download request
    /// Return an observable of raw DownloadResponse to keep data stable
    @inlinable
    public func pureDownload(api: API, options: DownloadRequestOption?) -> AnyPublisher<AFDownloadResponse<Data>, Error> {
        Future { promise in
            Task {
                do {
                    try await promise(.success(pureDownload(api: api, options: options)))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension PureHTTPRequest where Self: HTTPResponseTransformable {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    @inlinable
    public func execute(api: API, options: RequestOption?) -> AnyPublisher<Response, Error> {
        pureExecute(api: api, options: options).tryMap(transform).eraseToAnyPublisher()
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    @inlinable
    public func upload(api: API, options: UploadRequestOption) -> AnyPublisher<Response, Error> {
        pureUpload(api: api, options: options).tryMap(transform).eraseToAnyPublisher()
    }
}

extension PureHTTPRequest where API: HTTPResponseTransformable {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    @inlinable
    public func execute(api: API, options: RequestOption?) -> AnyPublisher<API.Response, Error> {
        pureExecute(api: api, options: options).tryMap(api.transform).eraseToAnyPublisher()
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    @inlinable
    public func upload(api: API, options: UploadRequestOption) -> AnyPublisher<API.Response, Error> {
        pureUpload(api: api, options: options).tryMap(api.transform).eraseToAnyPublisher()
    }
}
