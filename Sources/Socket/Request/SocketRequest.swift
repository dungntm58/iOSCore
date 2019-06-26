//
//  SocketRequest.swift
//  CoreCleanSwift
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import SocketIO
import RxSwift

/**
 * Should init socket client as below
 * let connectParams = SocketIOClientOption.connectParams(self.connectParams)
 * let socketConfig: SocketIOClientConfiguration = [
 *      SocketIOClientOption.log(false),
 *      SocketIOClientOption.forcePolling(true),
 *      connectParams,
 *      SocketIOClientOption.nsp(namespace)]
 * return socketClient = SocketIOClient(socketURL: URL(string: config.serverUrl)!, config: socketConfig)
 */

public protocol CleanSocketRequest: class {
    var socketClient: SocketIOClient { get }

    init(namespace: String)
}

public extension CleanSocketRequest {
    func connect() {
        socketClient.connect()
    }

    func disconnect() {
        socketClient.disconnect()
    }

    func send(message: String, _ data: SocketData...) {
        socketClient.emit(message, data)
    }

    func onObservable(event: String) -> Observable<[Any]> {
        return Observable.create {
            [weak self] subscribe in
            self?.socketClient.on(event) {
                data, ack in

                if data.isEmpty {
                    subscribe.onError(RxError.noElements)
                }
                else {
                    subscribe.onNext(data)
                }
            }

            return Disposables.create()
        }
    }
}
