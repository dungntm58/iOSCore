//
//  CoreDataIdentifiable.swift
//  CoreCoreData
//
//  Created by Robert Nguyen on 3/8/19.
//

import CoreRepository

public protocol CoreDataIdentifiable: Identifiable {
    static func keyPathForID() -> String
}
