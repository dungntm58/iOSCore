//
//  Box.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/16/19.
//

import CoreData

public protocol ManagedObjectBox {
    associatedtype Object: NSManagedObject
    
    var core: Object { get }
    init(core: Object)
}

extension MetaObjectEntity {
    var isValid: Bool {
        guard ttl <= 0 else {
            return true
        }
        let localUpdatedDate = Date(timeIntervalSince1970: localUpdatedTimestamp)
        return localUpdatedDate.addingTimeInterval(ttl) <= Date()
    }
}
