//
//  UserEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Foundation
import CoreBase
import CoreRepository
import CoreRealmDataStore
import Realm
import RealmSwift

class UserEntity: Object, Identifiable, Decodable {
    @objc dynamic var _id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    
    var id: String { _id }
    
    override open class func primaryKey() -> String? { "_id" }
    
    convenience init(_id: String, email: String, name: String) {
        self.init()
        self._id = _id
        self.email = email
        self.name = name
    }
}
