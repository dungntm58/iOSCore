//
//  DuplicationPolicy.swift
//  RxDifferenceKit
//
//  Created by svpcadmin on 2018/10/12.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import DifferenceKit

/// Policy for data whether distinct duplicates or not
///
/// - duplicatable: use duplicate data as it is
/// - unique: distinct duplicate data by handler
public enum DuplicationPolicy<T: Differentiable> {
    /// use duplicate data as it is
    case duplicatable
    /// distinct duplicate data by handler
    case unique(handler: UniqueHandler)

    /// Handler type to distinct duplicate data
    public typealias UniqueHandler = ([T]) -> [T]

    /// Handler to distinct duplicate data
    public static var uniqueHandler: UniqueHandler {
        return { original in
            var dictionary = [T.DifferenceIdentifier: Bool]()

            return original.filter({ o in dictionary.updateValue(true, forKey: o.differenceIdentifier) == nil })
        }
    }
}
