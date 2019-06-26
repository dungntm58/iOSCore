//
//  CoreDataIdentifiable.swift
//  CoreCleanSwiftCoreData
//
//  Created by Robert Nguyen on 3/8/19.
//

import CoreCleanSwiftBase

public protocol CoreDataIdentifiable: Identifiable {
    static func keyPathForID() -> String
}
