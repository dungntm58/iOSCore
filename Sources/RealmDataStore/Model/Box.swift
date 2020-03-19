//
//  Box.swift
//  CoreRealm
//
//  Created by Robert Nguyen on 3/16/19.
//

import RealmSwift

public protocol RealmObjectBox {
    associatedtype RealmObject: Object

    var core: RealmObject { get }
    init(core: RealmObject)
}
