//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase
import CoreDataStore
import CoreRepository

class TodoDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    let ttl: TimeInterval = 60
    
    func make(total: Int, page: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> Paginated? {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
