//
//  Model.swift
//  CoreList
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import DifferenceKit

public protocol ViewModelItem {
    func toAnyDifferentiable() -> AnyDifferentiable
}
