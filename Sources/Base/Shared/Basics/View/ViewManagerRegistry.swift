//
//  ViewManagerRegistry.swift
//  CoreBase
//
//  Registry for tracking ViewManager instances and their managed view controllers
//

import UIKit

/// Registry for tracking ViewManager instances
public class ViewManagerRegistry {
    public static let shared = ViewManagerRegistry()

    private var viewManagerMap: NSMapTable<UIViewController, ViewManager> = NSMapTable.weakToWeakObjects()

    private init() {}

    /// Registers a view controller as being managed by a ViewManager
    @usableFromInline
    func register(_ viewController: UIViewController, with viewManager: ViewManager) {
        viewManagerMap.setObject(viewManager, forKey: viewController)
    }

    /// Unregisters a view controller from its ViewManager
    @usableFromInline
    func unregister(_ viewController: UIViewController) {
        viewManagerMap.removeObject(forKey: viewController)
    }

    /// Finds the ViewManager that manages the given view controller
    public func findViewManager(for viewController: UIViewController) -> ViewManager? {
        viewManagerMap.object(forKey: viewController)
    }

    /// Registers all view controllers in a container with a ViewManager
    @usableFromInline
    func registerContainer(_ container: UIViewController, with viewManager: ViewManager) {
        register(container, with: viewManager)

        if let navigationController = container as? UINavigationController {
            navigationController.viewControllers.forEach { vc in
                register(vc, with: viewManager)
            }
        } else if let tabBarController = container as? UITabBarController {
            tabBarController.viewControllers?.forEach { vc in
                register(vc, with: viewManager)
            }
        }
    }
}
