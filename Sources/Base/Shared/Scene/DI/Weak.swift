//
//  Weak.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

protocol Prunable {
    var canBePruned: Bool { get }
}

struct Weak<T>: Prunable where T: AnyObject {

    weak var value: T?

    init(value: T?) {
        self.value = value
    }

    var canBePruned: Bool { value == nil }
}
