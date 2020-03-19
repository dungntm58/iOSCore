//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreDataStore
import RxCoreRepository

class UserDataStore: CoreDataIdentifiableDataStore {
    let configuration: CoreDataConfiguration
    
    func make(total: Int, size: Int, previous: UserEntity?, next: UserEntity?) -> PaginationDTO {
        AppPaginationDTO(total: total, pageSize: size, next: previous?.id as Any, previous: next?.id as Any)
    }
    
    init() {
        configuration = DefaultCoreDataConfiguration.instance
    }
}
