//
//  ViewManager.swift
//  CoreBase
//
//  Created by Robert on 7/21/19.
//

import UIKit
import SwiftUI
import CoreMacrosClient

open class ViewManager: ViewManagable, SceneReferencing {
    private(set) public var currentViewController: UIViewController?
    private(set) public var rootViewController: UIViewController

    public var scene: CoreMacroProtocols.Scene? {
        SceneAssociationRegistry.shared.scene(for: self)
    }

    public init(viewController: UIViewController) {
        self.rootViewController = viewController
        if let navigationController = viewController as? UINavigationController {
            self.currentViewController = navigationController.topViewController
            navigationController.viewControllers.forEach {
                addHook($0)
            }
        } else if let tabBarController = viewController as? UITabBarController {
            self.currentViewController = tabBarController.selectedViewController
            tabBarController.viewControllers?.forEach {
                addHook($0)
            }
        } else {
            self.currentViewController = viewController
        }
        if let currentViewController {
            addHook(currentViewController)
        }

        // Register this ViewManager with the registry
        ViewManagerRegistry.shared.registerContainer(rootViewController, with: self)
    }

    /// Convenience initializer for any ViewRepresentable content
    public convenience init<V: ViewRepresentable>(view: V) {
        let viewController = view.asViewController()
        self.init(viewController: viewController)
    }

    /// Create ViewManager with view wrapped in navigation controller
    public convenience init<V: ViewRepresentable>(view: V, withNavigation: Bool) {
        let viewController = view.asViewController()
        if withNavigation {
            let navigationController = UINavigationController(rootViewController: viewController)
            self.init(viewController: navigationController)
        } else {
            self.init(viewController: viewController)
        }
    }
}

extension ViewManager {
    @inlinable
    public func present(_ viewController: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Present view controller", type(of: viewController))
#endif
        addHook(viewController)
        // Register new view controller with this ViewManager
        ViewManagerRegistry.shared.register(viewController, with: self)
        currentViewController?.present(viewController, animated: true, completion: completion)
    }

    @inlinable
    public func pushViewController(_ viewController: UIViewController, animated flag: Bool) {
#if !RELEASE && !PRODUCTION
        Swift.print("Push view controller", type(of: viewController))
#endif
        addHook(viewController)
        // Register new view controller with this ViewManager
        ViewManagerRegistry.shared.register(viewController, with: self)
        (currentViewController as? UINavigationController ?? currentViewController?.navigationController)?.pushViewController(viewController, animated: true)
    }

    @inlinable
    public func show(_ viewController: UIViewController, sender: Any?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Show view controller", type(of: viewController))
#endif
        addHook(viewController)
        // Register new view controller with this ViewManager
        ViewManagerRegistry.shared.register(viewController, with: self)
        currentViewController?.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss root view controller")
#endif
        rootViewController.internalDismiss(animated: flag, completion: completion)
    }

    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss current view controller")
#endif
        guard let currentViewController else {
            return
        }
        currentViewController.internalDismiss(animated: flag, completion: completion)
    }
}

extension ViewManager {
    @usableFromInline
    func addHook(_ viewController: UIViewController) {
        LifecycleStorage.shared.addHandler({ [weak self] in
            self?.currentViewController = viewController
        }, for: .viewWillAppear, target: viewController)

        switch viewController.modalPresentationStyle {
        case .fullScreen, .currentContext:
            break
        case .formSheet, .pageSheet:
            if #available(iOS 13.0, *) {
                addHookViewWillDisappear(viewController)
            }
        case .popover:
            if #available(iOS 13.0, *) {
                addHookViewWillDisappear(viewController)
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                addHookViewWillDisappear(viewController)
            }
        default:
            addHookViewWillDisappear(viewController)
        }
    }

    private func addHookViewWillDisappear(_ viewController: UIViewController) {
        LifecycleStorage.shared.addHandler({ [weak self] in
            guard let presentingViewController = viewController.presentingViewController else { return }
            self?.currentViewController = presentingViewController
        }, for: .viewWillDisappear, target: viewController)
    }
}

private extension UIViewController {
    func internalDismiss(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let navigationController {
            if navigationController.viewControllers.first == self {
                navigationController.dismiss(animated: flag, completion: completion)
            } else if let completion = completion {
                navigationController.popViewController(animated: true, completion: completion)
            } else {
                navigationController.popViewController(animated: true)
            }
        } else if let tabBarController {
            tabBarController.dismiss(animated: flag, completion: completion)
        } else {
            dismiss(animated: flag, completion: completion)
        }
    }
}
