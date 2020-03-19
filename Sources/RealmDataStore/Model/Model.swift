//
//  Model.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 4/11/19.
//

import RealmSwift
import CoreRepository

open class ExpirableObject: Object, Expirable {
    @objc dynamic internal(set) open var localUpdatedDate: Date = Date()
    @objc dynamic internal(set) open var ttl: TimeInterval = 0

    override open class func shouldIncludeInDefaultSchema() -> Bool {
        Self.self !== ExpirableObject.self
    }
}
