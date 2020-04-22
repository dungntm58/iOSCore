//
//  RemoteLocalRepository.swift
//  CoreRemoteRepository
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol RemoteLocalListRepository: RemoteListRepository, LocalListRepository {}

public protocol RemoteLocalSingleRepository: RemoteSingleRepository, LocalSingleRepository {}

public protocol RemoteLocalIdentifiableSingleRepository: RemoteLocalSingleRepository, RemoteIdentifiableSingleRepository, LocalIdentifiableSingleRepository {}
