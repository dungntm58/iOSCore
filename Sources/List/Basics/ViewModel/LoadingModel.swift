//
//  LoadingModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 3/21/19.
//

import DifferenceKit

struct LoadingDifferentiable: Differentiable, Equatable {
    typealias DifferenceIdentifier = String

    let differenceIdentifier: String

    private init() {
        self.differenceIdentifier = UUID().uuidString
    }

    static let shared = LoadingDifferentiable()

    func isContentEqual(to source: LoadingDifferentiable) -> Bool { self == source }
}

func getLoadingDifferentiable() -> AnyDifferentiable {
    LoadingDifferentiable.shared.toAnyDifferentiable()
}
