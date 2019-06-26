//
//  RawHTTPRequest.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 5/13/19.
//

import Alamofire
import RxSwift
import CoreCleanSwiftBase

public protocol RawHTTPRequest: Request {
    associatedtype API: RequestAPI

    var sessionManager: SessionManager { get }

    /* Override this following method if authorization is required
     */
    var defaultHeaders: HTTPHeaders? { get }

    /* Default params is passed in HTTP Request
     */
    var defaultParams: Parameters? { get }

    /* Make request from api, options
     */
    func makeRequest(api: API, options: RequestOption?) throws -> URLRequestConvertible

    #if DEBUG
    static func mockFileName(for api: API, options: RequestOption?, header: HTTPHeaders?) -> String?

    var isMockTesting: Bool { get }
    #endif
}

#if DEBUG
public extension RawHTTPRequest {
    static func mockFileName(for api: API, options: RequestOption?, header: HTTPHeaders?) -> String? {
        return nil
    }

    var isMockTesting: Bool {
        get {
            return false
        }
    }
}
#endif

// MARK: - Default
public extension RawHTTPRequest {
    var defaultParams: Parameters? {
        get {
            return nil
        }
    }

    var sessionManager: SessionManager {
        get {
            return SessionManager.default
        }
    }
}

// MARK: - Convenience
public extension RawHTTPRequest {
    func makeRequest(api: API, options: RequestOption?) throws -> URLRequestConvertible {
        var headers = defaultHeaders
        if let extraHeaders = api.extraHeaders {
            if let _headers = headers {
                headers = _headers + extraHeaders
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

        #if DEBUG
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

    func rawExecute(api: API, options: RequestOption?) -> Observable<Data>{
        return .create {
            subscribe in
            var dataRequest: DataRequest!
            do {
                #if DEBUG
                if self.isMockTesting, let fileName = Self.mockFileName(for: api, options: options, header: self.defaultHeaders) {
                    do {
                        let data = try Utils.readFile(name: fileName)
                        subscribe.onNext(data)
                        subscribe.onCompleted()
                    } catch {
                        subscribe.onError(error)
                    }
                } else {
                    let request = try self.makeRequest(api: api, options: options)
                    dataRequest = self.sessionManager.request(request)
                    dataRequest.responseData {
                        response in
                        Swift.print(response)
                        if let data = response.data {
                            Swift.print("String represents", String(data: data, encoding: .utf8) as Any)
                        }
                        switch response.result {
                        case .success(let data):
                            subscribe.onNext(data)
                            subscribe.onCompleted()
                        case .failure(let error):
                            subscribe.onError(error)
                        }
                    }
                }
                #else
                let request = try self.makeRequest(api: api, options: options)
                dataRequest = self.sessionManager.request(request)
                dataRequest.responseData {
                    response in
                    switch response.result {
                    case .success(let data):
                        subscribe.onNext(data)
                        subscribe.onCompleted()
                    case .failure(let error):
                        subscribe.onError(error)
                    }
                }
                #endif
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak dataRequest] in
                dataRequest?.cancel()
            }
        }
    }

    func rawUpload(api: API, options: UploadRequestOption) -> Observable<Data> {
        return .create {
            subscribe in
            var uploadRequest: UploadRequest!
            do {
                switch options.type {
                case .data(let data):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(data, with: request)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .fileURL(let url):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(url, with: request)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .stream(let stream):
                    let request = try self.makeRequest(api: api, options: options)
                    uploadRequest = self.sessionManager.upload(stream, with: request)
                    self.watchUploadRequest(uploadRequest, options: options, subscribe: subscribe)
                case .multipart(let fileUploads, let key):
                    self.sessionManager.upload(multipartFormData: {
                        multipartFormData in
                        for fileUpload in fileUploads {
                            if let data = fileUpload.data {
                                multipartFormData.append(data, withName: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            } else if let inputStream = fileUpload.inputStream {
                                multipartFormData.append(inputStream, withLength: fileUpload.size, name: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            } else if let fileUrl = fileUpload.fileUrl {
                                multipartFormData.append(fileUrl, withName: key, fileName: fileUpload.fileName, mimeType: fileUpload.mimeType)
                            }
                        }
                        if let params = options.parameters {
                            for (key, value) in params {
                                if let data = String(describing: value).data(using: .utf8) {
                                    multipartFormData.append(data, withName: key)
                                }
                            }
                        }
                    }, to: "\(self.environment.config.defaultServerUrl)\(api.endPoint)") {
                        encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            uploadRequest = upload
                            self.watchUploadRequest(upload, options: options, subscribe: subscribe)
                        case .failure(let error):
                            subscribe.onError(error)
                        }
                    }
                }
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak uploadRequest] in
                uploadRequest?.cancel()
            }
        }
    }

    /* Download request
     * Return an observable of raw DownloadResponse to keep data stable
     */
    func download(api: API, options: DownloadRequestOption?) -> Observable<DownloadResponse<Data>> {
        return .create {
            subscribe in
            var downloadRequest: DownloadRequest!
            do {
                let request = try self.makeRequest(api: api, options: options)
                downloadRequest = self.sessionManager.download(request, to: options?.downloadFileDestination?.make)
                if let tracking = options?.tracking {
                    downloadRequest.downloadProgress(queue: tracking.queue, closure: tracking.handle)
                }
                downloadRequest.responseData {
                    response in
                    #if DEBUG
                    Swift.print(response)
                    #endif
                    if let error = response.error {
                        return subscribe.onError(error)
                    }
                    subscribe.onNext(response)
                    subscribe.onCompleted()
                }
            } catch {
                subscribe.onError(error)
            }
            return Disposables.create {
                [weak downloadRequest] in
                downloadRequest?.cancel()
            }
        }
    }

    // MARK: - Generic transform data generator
    static func transform<Response>(to: Response.Type, decoder: JSONDecoder) -> (Data) throws -> Response where Response: HTTPResponse {
        return {
            data in
            let httpResponse = try decoder.decode(Response.self, from: data)
            if httpResponse.success {
                return httpResponse
            } else {
                throw ResponseError(code: httpResponse.errorCode, message: httpResponse.message, data: data)
            }
        }
    }
}

extension RawHTTPRequest {
    func watchUploadRequest(_ request: UploadRequest, options: UploadRequestOption, subscribe: AnyObserver<Data>) {
        if let tracking = options.tracking {
            request.uploadProgress(queue: tracking.queue, closure: tracking.handle)
        }
        request.responseData {
            response in
            #if DEBUG
            Swift.print(response)
            if let data = response.data {
                Swift.print("String represents", String(data: data, encoding: .utf8) as Any)
            }
            #endif
            switch response.result {
            case .success(let data):
                subscribe.onNext(data)
                subscribe.onCompleted()
            case .failure(let error):
                subscribe.onError(error)
            }
        }
    }
}
