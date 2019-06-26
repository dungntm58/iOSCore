//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RealmSwift
import CoreRealm
import CoreBase

class UserDataStore: RealmIdentifiableDataStore {
    let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func make(total: Int, size: Int, before: UserEntity?, after: UserEntity?) -> PaginationResponse {
        return AppPaginationResponse(total: total, pageSize: size, after: after?.id as Any, before: before?.id as Any)
    }
}
