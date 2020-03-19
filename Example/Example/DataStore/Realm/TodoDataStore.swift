//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RealmSwift
import RxCoreRealmDataStore
import RxCoreBase
import RxCoreRepository

class TodoDataStore: RealmIdentifiableDataStore {
    let realm: Realm
    let updatePolicy: Realm.UpdatePolicy
    
    init() {
        self.realm = try! Realm()
        self.updatePolicy = .all
    }
    
    func make(total: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> PaginationDTO {
        AppPaginationDTO(total: total, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
}
