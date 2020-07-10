//
//  Weak.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

struct AnyWeak {

    weak var value: AnyObject?

    init(value: AnyObject?) {
        self.value = value
    }

    var canBePruned: Bool { value == nil }
}
