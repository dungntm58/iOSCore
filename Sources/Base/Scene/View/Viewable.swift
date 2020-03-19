//
//  Viewable.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 6/6/19.
//

import RxSwift

public protocol Viewable {
    var viewManager: ViewManagable { get }
}

// Shortcut
public extension Viewable {
    var currentViewController: UIViewController {
        viewManager.currentViewController
    }

    /// Present a view controller from the current view controller
    func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        viewManager.present(viewController, animated: flag, completion: completion)
    }

    /// Push a view controller to the current navigation controller if possible
    func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
        viewManager.pushViewController(viewController, animated: flag)
    }

    /// Show a view controller from the current view controller
    func show(_ viewController: UIViewController, sender: Any? = nil) {
        viewManager.show(viewController, sender: sender)
    }

    /// Back to previous view controller from the current view controller
    /// If the current view controller is root, this acts same as dismiss
    func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        viewManager.goBack(animated: flag, completion: completion)
    }
}
