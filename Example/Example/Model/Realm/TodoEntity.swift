//
//  TodoEntity.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import DifferenceKit
import RealmSwift
import RxCoreRepository
import RxCoreRealmDataStore
import RxCoreBase

class TodoEntity: ExpirableObject, Identifiable, Decodable {
    @objc dynamic var _id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var completed: Bool = false
    @objc dynamic var owner: String = ""
    @objc dynamic var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case _id
        case title
        case completed
        case owner
        case createdAt = "created"
    }
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    var id: String { _id }
    
    func toLiteralDictionary() -> [String: Any] {
        [
            "title": title
        ]
    }
    
    override open class func primaryKey() -> String? { "_id" }
}
