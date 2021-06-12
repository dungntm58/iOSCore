//
//  UserDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RealmSwift
import CoreRealmDataStore
import CoreBase
import CoreRepository

class UserDataStore: RealmIdentifiableDataStore {
    let realm: Realm
    let updatePolicy: Realm.UpdatePolicy
    
    init() {
        self.realm = try! Realm()
        self.updatePolicy = .all
    }
    
    func make(total: Int, page: Int, size: Int, previous: UserEntity?, next: UserEntity?) -> Paginated {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
}
