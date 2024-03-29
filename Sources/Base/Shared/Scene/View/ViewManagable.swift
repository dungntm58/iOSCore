//
//  ViewManagable.swift
//  CoreBase
//
//  Created by Robert on 8/28/19.
//

import UIKit

public protocol HasViewManagable {
    associatedtype ViewManager where ViewManager: ViewManagable

    var viewManager: ViewManager? { get }
}

extension HasViewManagable {
    @inlinable
    var anyViewManager: ViewManagable? { viewManager }
}

public protocol ViewManagable {
    /// The current view controller that scene presents
    var currentViewController: UIViewController? { get }

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

    /// Present a view manager from the current view controller
    func present(_ viewManager: ViewManagable, animated flag: Bool, completion: (() -> Void)?)

    /// Push a view manager to the current navigation controller if possible
    func pushViewController(_ viewManager: ViewManagable, animated flag: Bool)

    /// Show a view manager from the current view controller
    func show(_ viewManager: ViewManagable, sender: Any?)
}

extension ViewManagable {

    @inlinable
    public func present(_ viewController: UIViewController, animated flag: Bool) {
        present(viewController, animated: flag, completion: nil)
    }

    @inlinable
    public func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    @inlinable
    public func pushViewController(_ viewController: UIViewController) {
        pushViewController(viewController, animated: true)
    }

    @inlinable
    public func show(_ viewController: UIViewController) {
        show(viewController, sender: nil)
    }

    @inlinable
    public func goBack(animated flag: Bool) {
        goBack(animated: flag, completion: nil)
    }

    @inlinable
    public func goBack() {
        goBack(animated: true, completion: nil)
    }

    @inlinable
    public func dismiss(animated flag: Bool) {
        dismiss(animated: flag, completion: nil)
    }

    @inlinable
    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    @inlinable
    public func present(_ viewManager: ViewManagable, animated flag: Bool, completion: (() -> Void)?) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.present(destinationViewController, animated: flag, completion: completion)
    }

    @inlinable
    public func pushViewController(_ viewManager: ViewManagable, animated flag: Bool) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.navigationController?.pushViewController(destinationViewController, animated: flag)
    }

    @inlinable
    public func show(_ viewManager: ViewManagable, sender: Any?) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.show(destinationViewController, sender: sender)
    }
}

extension ViewManagable where Self: UIViewController {

    @inlinable
    public var currentViewController: UIViewController? { self }

    @inlinable
    public func pushViewController(_ viewController: UIViewController, animated flag: Bool) {
        (self as? UINavigationController ?? navigationController)?.pushViewController(viewController, animated: true)
    }

    @inlinable
    public func goBack(animated flag: Bool, completion: (() -> Void)?) {
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
