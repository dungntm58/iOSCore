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
import RealmSwift
import FoundationExtInternal

class UserEntity: Object, Identifiable, Decodable {
    typealias IDType = String
    
    @objc dynamic var _id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    
    var id: IDType { _id }
    
    override open class func primaryKey() -> String? { "_id" }
}
