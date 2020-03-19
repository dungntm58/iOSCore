//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreDataStore
import RxCoreRepository

class TodoDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    let ttl: TimeInterval = 60
    
    func make(total: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> PaginationDTO {
        AppPaginationDTO(total: total, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
