//
//  Model.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import DifferenceKit

public protocol CleanViewModelItem {
    func toAnyDifferentiable() -> AnyDifferentiable
}