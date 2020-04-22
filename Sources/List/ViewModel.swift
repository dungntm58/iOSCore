//
//  Model.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 1/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import DifferenceKit

public protocol ViewModelItem {
    func toAnyEquatable() -> AnyEquatable
}

extension ViewModelItem where Self: Equatable {
    public func toAnyEquatable() -> AnyEquatable { .init(self) }
}

@frozen
public enum HeaderFooterPosition {
    case header
    case footer
}

extension AnyHashable: Differentiable {}

public struct UniqueIdentifier: Hashable {
    public init() {}
}

public struct LoadingIdentifier: Hashable {}
