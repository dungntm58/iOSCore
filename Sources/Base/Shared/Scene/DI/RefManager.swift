//
//  RefManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

private class WeakScenable {

    weak var value: Scenable?

    init(value: Scenable?) {
        self.value = value
    }
}

@frozen enum RefManager {

    // Key: view controller's hash value
    // Value: weak ref of scenable instance
    private static var sceneDictionary: [Int: WeakScenable] = [:]

    static func getScene<S>(_ viewControllerHash: Int) -> S? where S: Scenable {
        sceneDictionary[viewControllerHash]?.value as? S
    }

    static func setScene(_ scene: Scenable?, associatedViewController viewController: UIViewController) {
        sceneDictionary[viewController.hashValue] = WeakScenable(value: scene)
        for (key, value) in sceneDictionary {
            if value.value == nil {
                sceneDictionary[key] = nil
            }
        }
    }
}
