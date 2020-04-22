//
//  RemoteRepository.swift
//  CoreRemoteRepository
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol RemoteListRepository: ListModelRepository  where ListRequest.Response.ValueType == T {
    associatedtype ListRequest: ListModelHTTPRequest

    var listRequest: ListRequest { get }
}

public protocol RemoteSingleRepository: SingleModelRepository where SingleRequest.Response.ValueType == T {
    associatedtype SingleRequest: SingleModelHTTPRequest

    var singleRequest: SingleRequest { get }
}

public protocol RemoteIdentifiableSingleRepository: RemoteSingleRepository, IdentifiableSingleRepository where SingleRequest: IdentifiableSingleHTTPRequest {}
