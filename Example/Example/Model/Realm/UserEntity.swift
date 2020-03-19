//
//  UserEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxCoreBase
import RxCoreRepository
import RxCoreRealmDataStore
import RealmSwift

class UserEntity: Object, Identifiable, Decodable {
    typealias IDType = String
    
    @objc dynamic var _id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    
    var id: IDType { _id }
    
    override open class func primaryKey() -> String? { "_id" }
}
