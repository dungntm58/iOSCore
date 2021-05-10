//
//  ReferenceManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation

public protocol ViewControllerLookingForAssociatedScene where Self: UIViewController {
    func sceneAssociatedViewController() -> UIViewController?
}

@usableFromInline
@frozen enum ReferenceManager {

    // Key: view controller's hash value
    // Value: weak ref of scenable instance
    private static var sceneDictionary: [Int: AnyWeak] = [:]

    static func getScene<S>(associatedWith viewController: UIViewController) -> S? {
        if let scene = sceneDictionary[viewController.hashValue]?.value as? S {
            return scene
        }
        if let viewController = viewController as? ViewControllerLookingForAssociatedScene,
            let associatedSceneViewController = viewController.sceneAssociatedViewController(),
            let scene = sceneDictionary[associatedSceneViewController.hashValue]?.value as? S {
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

    // swiftlint:disable cyclomatic_complexity
    static func getAbstractScene(associatedWith viewController: UIViewController) -> Scenable? {
        if let scene = sceneDictionary[viewController.hashValue]?.value {
            if let scene = scene as? Scenable {
                return scene
            }
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
    // swiftlint:enable cyclomatic_complexity

    @usableFromInline
    static func setScene(_ scene: Scenable?, associatedViewController viewController: UIViewController) {
        for (key, value) in sceneDictionary where value.canBePruned {
            sceneDictionary[key] = nil
        }
        let weakScene = AnyWeak(value: scene)
        pureSetWeakScene(weakScene, associatedTopViewController: viewController)
        pureSetWeakScene(weakScene, associatedBottomViewController: viewController)
    }

    private static func pureSetWeakScene(_ scene: AnyWeak, associatedTopViewController viewController: UIViewController) {
        if !sceneDictionary.keys.contains(viewController.hashValue) {
            sceneDictionary[viewController.hashValue] = scene
        }
        if let parent = viewController.parent {
            pureSetWeakScene(scene, associatedTopViewController: parent)
        }
        if let presentedViewController = viewController.presentedViewController {
            pureSetWeakScene(scene, associatedTopViewController: presentedViewController)
        }
        if let tabBarController = viewController.tabBarController {
            tabBarController.viewControllers?.forEach {
                pureSetWeakScene(scene, associatedTopViewController: $0)
            }
        } else if let navigationController = viewController.navigationController {
            navigationController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedTopViewController: $0)
            }
        } else if let splitController = viewController.splitViewController {
            splitController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedTopViewController: $0)
            }
        }
    }

    private static func pureSetWeakScene(_ scene: AnyWeak, associatedBottomViewController viewController: UIViewController) {
        if !sceneDictionary.keys.contains(viewController.hashValue) {
            sceneDictionary[viewController.hashValue] = scene
        }
        viewController.children.forEach {
            pureSetWeakScene(scene, associatedBottomViewController: $0)
        }
        if let presentingViewController = viewController.presentingViewController {
            pureSetWeakScene(scene, associatedBottomViewController: presentingViewController)
        }
        if let tabBarController = viewController as? UITabBarController {
            tabBarController.viewControllers?.forEach {
                pureSetWeakScene(scene, associatedBottomViewController: $0)
            }
        } else if let navigationController = viewController as? UINavigationController {
            navigationController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedBottomViewController: $0)
            }
        } else if let splitController = viewController.splitViewController {
            splitController.viewControllers.forEach {
                pureSetWeakScene(scene, associatedBottomViewController: $0)
            }
        }
    }
}
