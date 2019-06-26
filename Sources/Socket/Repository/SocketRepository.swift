//
//  SocketRepository.swift
//  CoreCleanSwift
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import SocketIO
import CoreCleanSwiftBase

/* Particular repository
 * Communicate with socket
 */

public protocol CleanSocketRepository {

    var authorization: [String: Any] { get }
    var decoder: JSONDecoder { get }

    func connectSocket()
    func disconnectSocket()

    func addReceiveDataObservable<T>(of type: T.Type, withEvent event: String) where T: Decodable
    func observable<T>(with event: String) -> Observable<T>? where T: Decodable
}

open class BaseCleanSocketRepository<SocketRequest>: CleanSocketRepository where SocketRequest: CleanSocketRequest {
    private var observables: [String: Any]
    private var namespace: String

    private lazy var socketRequest: SocketRequest = {
        return initSocketRequest(namespace: self.namespace)
    }()

    public init(namespace: String) {
        self.namespace = namespace
        self.observables = [:]
    }

    open func initSocketRequest(namespace: String) -> SocketRequest {
        return SocketRequest(namespace: namespace)
    }

    public func observable<T>(with event: String) -> Observable<T>? where T: Decodable {
        return observables[event] as? Observable<T>
    }

    /* Do receive data from socket request
     * Executing this method will append an observable into array of observables
     */
    public func addReceiveDataObservable<T>(of type: T.Type, withEvent event: String) where T: Decodable {
        let obs: Observable<T> = self.socketRequest.onObservable(event: event)
            .flatMap {
                data -> Observable<T> in
                if let value: T = self.map(data: data, with: event) {
                    return Observable.just(value)
                }

                return Observable.error(RxError.noElements)
            }
            .share()
        observables[event] = obs
    }

    public func connectSocket() {
        socketRequest.connect()
    }

    public func disconnectSocket() {
        socketRequest.disconnect()
    }

    public func send(message: String, _ data: [String: Any]) {
        socketRequest.send(message: message, data + authorization)
    }

    open var authorization: [String : Any] {
        return [:]
    }

    open var decoder: JSONDecoder {
        get {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = .current
            formatter.locale = .current
            decoder.dateDecodingStrategy = .formatted(formatter)

            return decoder
        }
    }

    open func map<T>(data: [Any], with event: String) -> T? where T: Decodable {
        guard let data = data[0] as? Data else {
            return nil
        }

        if let decodeData = try? decoder.decode(T.self, from: data) {
            return decodeData
        }

        return nil
    }
}
