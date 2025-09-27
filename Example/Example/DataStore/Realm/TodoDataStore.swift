//
//  TodoDataStore.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RealmSwift
import CoreRealmDataStore
import CoreBase
import CoreRepository
import CoreRepositoryDataStore
import Foundation

class TodoDataStore: RealmIdentifiableDataStore {
    let realm: Realm
    let updatePolicy: Realm.UpdatePolicy
    let ttl: TimeInterval = 60
    
    init() {
        self.realm = try! Realm()
        self.updatePolicy = .all
    }
    
    func make(total: Int, page: Int, size: Int, previous: TodoEntity?, next: TodoEntity?) -> Paginated? {
        AppPaginationDTO(total: total, page: page, pageSize: size, next: next?.id as Any, previous: previous?.id as Any)
    }
}
