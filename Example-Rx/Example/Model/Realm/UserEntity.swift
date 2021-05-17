//
//  UserEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreRepository
import CoreRealmDataStore
import RealmSwift
import FoundationExt_R

class UserEntity: Object, Identifiable, Decodable {
    typealias ID = String
    
    @objc dynamic var _id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    
    var id: ID { _id }
    
    override open class func primaryKey() -> String? { "_id" }
}
