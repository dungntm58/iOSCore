//
//  CoreDataIdentifiable.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/8/19.
//

import CoreData
import CoreRepository

public protocol ManagedObjectWrapper {
    associatedtype Object: NSManagedObject

    init(object: Object)
    func toObject() -> Object
}

extension MetaObjectEntity {
    @inlinable
    var isValid: Bool {
        guard ttl <= 0 else {
            return true
        }
        let localUpdatedDate = Date(timeIntervalSince1970: localUpdatedTimestamp)
        return localUpdatedDate.addingTimeInterval(ttl) <= Date()
    }
}

public protocol CoreDataIdentifiable: Identifiable {
    static func keyPathForID() -> String
}
