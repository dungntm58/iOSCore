//
//  ReferenceManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

@frozen enum ReferenceManager {

    // Key: view controller's hash value
    // Value: weak ref of scenable instance
    private static var sceneDictionary: [Int: AnyWeak] = [:]

    static func getScene<S>(associatedWith viewController: UIViewController) -> S? where S: Scenable {
        if let scene = sceneDictionary[viewController.hashValue]?.value as? S {
            return scene
        }
        if let scene: S = viewController.parent.flatMap(getScene(associatedWith:)) {
            return scene
        }
        if let scene: S = viewController.presentedViewController.flatMap(getScene(associatedWith:)) {
            return scene
        }
        if let scene: S = viewController.tabBarController.flatMap(getScene(associatedWith:)) {
            return scene
        }
        if let scene: S = viewController.navigationController.flatMap(getScene(associatedWith:)) {
            return scene
        }
        if let scene: S = viewController.splitViewController.flatMap(getScene(associatedWith:)) {
            return scene
        }
        return nil
    }

    static func setScene(_ scene: Scenable?, associatedViewController viewController: UIViewController) {
        for (key, value) in sceneDictionary {
            if value.canBePruned {
                sceneDictionary[key] = nil
            }
        }
        let weakScene = AnyWeak(value: scene)
        pureSetWeakScene(weakScene, associatedViewController: viewController)
    }

    private static func pureSetWeakScene(_ scene: AnyWeak, associatedViewController viewController: UIViewController) {
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
