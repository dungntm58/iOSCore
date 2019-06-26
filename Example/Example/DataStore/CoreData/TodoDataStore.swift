//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreCoreData

class TodoDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    let ttl: TimeInterval = 60
    
    func make(total: Int, size: Int, before: TodoEntity?, after: TodoEntity?) -> PaginationResponse {
        return AppPaginationResponse(total: total, pageSize: size, after: after?.id as Any, before: before?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
