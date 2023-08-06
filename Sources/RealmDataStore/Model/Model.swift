//
//  Model.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 4/11/19.
//

import Foundation
import RealmSwift
import CoreRepository

public protocol RealmObjectWrapper {
    associatedtype RealmObject: Object

    init(object: RealmObject)
    func toObject() -> RealmObject
}

open class ExpirableObject: Object, Expirable {
    @Persisted open var localUpdatedDate: Date = Date()
    @Persisted open var ttl: TimeInterval = 0

    override open class func shouldIncludeInDefaultSchema() -> Bool {
        Self.self !== ExpirableObject.self
    }
}
