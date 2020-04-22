//
//  LocalRepository.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public protocol LocalRepository: ModelRepository where T == DS.T {
    associatedtype DS: DataStore

    var store: DS { get }
}

public protocol LocalListRepository: LocalRepository, ListModelRepository {}

public protocol LocalSingleRepository: LocalRepository, SingleModelRepository {}

public protocol LocalIdentifiableSingleRepository: IdentifiableSingleRepository, LocalSingleRepository where DS: IdentifiableDataStore {}
