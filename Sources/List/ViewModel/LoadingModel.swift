//
//  LoadingModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 3/21/19.
//

import DifferenceKit

struct LoadingDifferentiable: Differentiable, Equatable {
    var differenceIdentifier: String {
        return "LoadingDifferentiable"
    }

    typealias DifferenceIdentifier = String

    func isContentEqual(to source: LoadingDifferentiable) -> Bool {
        return self == source
    }

    private init() {}

    static let shared: LoadingDifferentiable = {
        return LoadingDifferentiable()
    }()
}

func getLoadingDifferentiable() -> AnyDifferentiable {
    return LoadingDifferentiable.shared.toAnyDifferentiable()
}
