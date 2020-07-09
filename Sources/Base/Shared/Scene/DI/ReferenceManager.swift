//
//  ReferenceManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

private class WeakScenable: Prunable {

    weak var value: Scenable?

    init(value: Scenable?) {
        self.value = value
    }

    var canBePruned: Bool { value == nil }
}

@frozen enum ReferenceManager {

    // Key: view controller's hash value
    // Value: weak ref of scenable instance
    private static var sceneDictionary: [Int: WeakScenable] = [:]

    static func getScene<S>(associatedWith viewController: UIViewController) -> S? where S: Scenable {
        if let scene = sceneDictionary[viewController.hashValue]?.value as? S {
            return scene
        }
        if let parent = viewController.parent {
            if let scene: S = getScene(associatedWith: parent) {
                return scene
            }
        }
        if let presentedViewController = viewController.presentedViewController {
            if let scene: S = getScene(associatedWith: presentedViewController) {
                return scene
            }
        }
        if let tabBarController = viewController.tabBarController {
            if let scene: S = getScene(associatedWith: tabBarController) {
                return scene
            }
        } else if let navigationController = viewController.navigationController {
            if let scene: S = getScene(associatedWith: navigationController) {
                return scene
            }
        } else if let splitController = viewController.splitViewController {
            if let scene: S = getScene(associatedWith: splitController) {
                return scene
            }
        }
        return nil
    }

    static func getAbstractScene(associatedWith viewController: UIViewController) -> Scenable? {
        if let scene = sceneDictionary[viewController.hashValue]?.value {
            return scene
        }
        if let parent = viewController.parent {
            if let scene = getAbstractScene(associatedWith: parent) {
                return scene
            }
        }
        if let presentedViewController = viewController.presentedViewController {
            if let scene = getAbstractScene(associatedWith: presentedViewController) {
                return scene
            }
        }
        if let tabBarController = viewController.tabBarController {
            if let scene = getAbstractScene(associatedWith: tabBarController) {
                return scene
            }
        } else if let navigationController = viewController.navigationController {
            if let scene = getAbstractScene(associatedWith: navigationController) {
                return scene
            }
        } else if let splitController = viewController.splitViewController {
            if let scene = getAbstractScene(associatedWith: splitController) {
                return scene
            }
        }
        return nil
    }

    static func setScene(_ scene: Scenable?, associatedViewController viewController: UIViewController) {
        for (key, value) in sceneDictionary {
            if value.canBePruned {
                sceneDictionary[key] = nil
            }
        }
        let weakScene = WeakScenable(value: scene)
        pureSetWeakScene(weakScene, associatedViewController: viewController)
    }

    private static func pureSetWeakScene(_ scene: WeakScenable, associatedViewController viewController: UIViewController) {
        if sceneDictionary.keys.contains(viewController.hashValue) { return }
        if let parent = viewController.parent {
            pureSetWeakScene(scene, associatedViewController: parent)
        }
        if let presentedViewController = viewController.presentedViewController {
            pureSetWeakScene(scene, associatedViewController: presentedViewController)
        }
        if let tabBarController = viewController.tabBarController {
            tabBarController.viewControllers?.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        } else if let navigationController = viewController.navigationController {
            navigationController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        } else if let splitController = viewController.splitViewController {
            splitController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        }
        viewController.children.forEach {
            pureSetWeakScene(scene, associatedViewController: $0)
        }
        if let presentingViewController = viewController.presentingViewController {
            pureSetWeakScene(scene, associatedViewController: presentingViewController)
        }
        if let tabBarController = viewController as? UITabBarController {
            tabBarController.viewControllers?.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        } else if let navigationController = viewController as? UINavigationController {
            navigationController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        } else if let splitController = viewController.splitViewController {
            splitController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedViewController: $0)
            }
        }
    }
}
