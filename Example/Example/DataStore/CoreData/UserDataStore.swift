//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreDataStore
import CoreRepository
import Foundation

class UserDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    var ttl: TimeInterval = 60
    
    func make(total: Int, page: Int, size: Int, previous: UserEntity?, next: UserEntity?) -> Paginated? {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: previous?.id as Any, previous: next?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
