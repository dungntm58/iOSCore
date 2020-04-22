//
//  RawHTTPRequest+Extension.swift
//  CoreRequest
//
//  Created by Robert Nguyen on 5/13/19.
//

import Alamofire
import Combine

// MARK: - Convenience
public extension PureHTTPRequest {
    func pureExecute(api: API, options: RequestOption?) -> AnyPublisher<AFDataResponse<Data>, Error>{
        Deferred {
            Future<AFDataResponse<Data>, Error> {
                promise in
                var dataRequest: DataRequest!
                let acceptableStatusCodes: [Int]
                if api.acceptableStatusCodes.isEmpty {
                    acceptableStatusCodes = self.acceptableStatusCodes
                } else {
                    acceptableStatusCodes = api.acceptableStatusCodes
                }
                do {
                    let request = try self.makeRequest(api: api, options: options)
                    dataRequest = self.session.request(request).validate(statusCode: acceptableStatusCodes)
                    dataRequest.responseData {
                        response in
                        #if !RELEASE && !PRODUCTION
                        Swift.print(response)
                        if let data = response.data {
                            printDebug(data: data)
                        }
                        #endif
                        promise(.success(response))
                    }
                } catch {
                    #if !RELEASE && !PRODUCTION
                    Swift.print("Response error", error as NSError)
                    #endif
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func pureUpload(api: API, options: UploadRequestOption) -> AnyPublisher<AFDataResponse<Data>, Error> {
        Deferred {
            Future {
                promise in
                var uploadRequest: UploadRequest!
                let acceptableStatusCodes: [Int]
                if api.acceptableStatusCodes.isEmpty {
                    acceptableStatusCodes = self.acceptableStatusCodes
                } else {
                    acceptableStatusCodes = api.acceptableStatusCodes
                }
                do {
                    switch options.type {
                    case .data(let data):
                        let request = try self.makeRequest(api: api, options: options)
                        uploadRequest = self.session.upload(data, with: request).validate(statusCode: acceptableStatusCodes)
                    case .fileURL(let url):
                        let request = try self.makeRequest(api: api, options: options)
                        uploadRequest = self.session.upload(url, with: request).validate(statusCode: acceptableStatusCodes)
                    case .stream(let stream):
                        let request = try self.makeRequest(api: api, options: options)
                        uploadRequest = self.session.upload(stream, with: request).validate(statusCode: acceptableStatusCodes)
                    case .multipart(let fileUploads, let key):
                        let request = try self.makeRequest(api: api, options: options)
                        uploadRequest = self.session.upload(multipartFormData: {
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
                        }, with: request).validate(statusCode: acceptableStatusCodes)
                    }
                    if let tracking = options.tracking {
                        uploadRequest = uploadRequest.uploadProgress(queue: tracking.queue, closure: tracking.handle)
                    }
                    uploadRequest.responseData {
                        response in
                        #if !RELEASE && !PRODUCTION
                        Swift.print(response)
                        if let data = response.data {
                            printDebug(data: data)
                        }
                        #endif
                        promise(.success(response))
                    }
                } catch {
                    #if !RELEASE && !PRODUCTION
                    Swift.print("Response error", error as NSError)
                    #endif
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Download request
    /// Return an observable of raw DownloadResponse to keep data stable
    func pureDownload(api: API, options: DownloadRequestOption?) -> AnyPublisher<AFDownloadResponse<Data>, Error> {
        Deferred {
            Future {
                promise in
                var downloadRequest: DownloadRequest!
                let acceptableStatusCodes: [Int]
                if api.acceptableStatusCodes.isEmpty {
                    acceptableStatusCodes = self.acceptableStatusCodes
                } else {
                    acceptableStatusCodes = api.acceptableStatusCodes
                }
                do {
                    let request = try self.makeRequest(api: api, options: options)
                    downloadRequest = self.session.download(request, to: options?.downloadFileDestination?.make).validate(statusCode: acceptableStatusCodes)
                    if let tracking = options?.tracking {
                        downloadRequest.downloadProgress(queue: tracking.queue, closure: tracking.handle)
                    }
                    downloadRequest.responseData {
                        response in
                        #if !RELEASE && !PRODUCTION
                        Swift.print(response)
                        if let data = response.value {
                            printDebug(data: data)
                        }
                        #endif
                        promise(.success(response))
                    }
                } catch {
                    #if !RELEASE && !PRODUCTION
                    Swift.print("Response error", error as NSError)
                    #endif
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

#if !RELEASE && !PRODUCTION
private func printDebug(data: Data) {
    do {
        let serialization = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        switch serialization {
        case let dict as [String: Any]:
            Swift.print("Response represents", dict)
        case let array as Array<Any>:
            Swift.print("Response represents", array)
        default:
            Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
        }
    } catch {
        Swift.print("Response string represents", String(data: data, encoding: .utf8) as Any)
    }
}
#endif

public extension PureHTTPRequest where Self: HTTPResponseTransformable {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    func execute(api: API, options: RequestOption?) -> AnyPublisher<Response, Error> {
        pureExecute(api: api, options: options).tryMap(transform).eraseToAnyPublisher()
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    func upload(api: API, options: UploadRequestOption) -> AnyPublisher<Response, Error> {
        pureUpload(api: api, options: options).tryMap(transform).eraseToAnyPublisher()
    }
}

public extension PureHTTPRequest where API: HTTPResponseTransformable {
    /// Common HTTP request
    /// Return an observable of HTTPResponse to keep data stable
    func execute(api: API, options: RequestOption?) -> AnyPublisher<API.Response, Error>{
        pureExecute(api: api, options: options).tryMap(api.transform).eraseToAnyPublisher()
    }

    /// Upload request
    /// Return an observable of HTTPResponse to keep data stable
    func upload(api: API, options: UploadRequestOption) -> AnyPublisher<API.Response, Error> {
        pureUpload(api: api, options: options).tryMap(api.transform).eraseToAnyPublisher()
    }
}
