//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreCoreData

class UserDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    
    func make(total: Int, size: Int, before: UserEntity?, after: UserEntity?) -> PaginationResponse {
        return AppPaginationResponse(total: total, pageSize: size, after: after?.id as Any, before: before?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
