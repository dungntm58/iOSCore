//
//  ViewManagable.swift
//  RxCoreBase
//
//  Created by Robert on 8/28/19.
//

public protocol ViewManagable {
    /// The current view controller that scene presents
    var currentViewController: UIViewController { get }

    /// Present a view controller from the current view controller
    func present(_ viewController: UIViewController, animated flag: Bool, completion: (() -> Void)?)

    /// Push a view controller to the current navigation controller if possible
    func pushViewController(_ viewController: UIViewController, animated flag: Bool)

    /// Show a view controller from the current view controller
    func show(_ viewController: UIViewController, sender: Any?)

    /// Back to previous view controller from the current view controller
    /// If the current view controller is root, this acts same as dismissing
    func goBack(animated flag: Bool, completion: (() -> Void)?)

    /// Dismiss the root view controller
    /// Do not call without detaching the scene, it may cause some memory issues
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

public extension ViewManagable where Self: UIViewController {
    var currentViewController: UIViewController { self }

    func pushViewController(_ viewController: UIViewController, animated flag: Bool) {
        (self.currentViewController as? UINavigationController ?? self.currentViewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    func goBack(animated flag: Bool, completion: (() -> Void)?) {
        if let naviViewController = navigationController {
            if naviViewController.viewControllers.first == self {
                naviViewController.dismiss(animated: flag, completion: completion)
            } else if let completion = completion {
                naviViewController.popViewController(animated: true, completion: completion)
            } else {
                naviViewController.popViewController(animated: true)
            }
        } else if let tabbarViewController = tabBarController {
            tabbarViewController.dismiss(animated: flag, completion: completion)
        } else {
            dismiss(animated: flag, completion: completion)
        }
    }
}
