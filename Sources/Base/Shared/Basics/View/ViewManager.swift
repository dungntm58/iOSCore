//
//  ViewManager.swift
//  CoreBase
//
//  Created by Robert on 7/21/19.
//

import UIKit

open class ViewManager: SceneAssociated {
    private(set) public var currentViewController: UIViewController?
    private(set) public var rootViewController: UIViewController

    fileprivate(set) public weak var scene: Scened?

    public init(viewController: UIViewController) {
        _ = UIViewController.swizzle
        self.rootViewController = viewController
        if let navigationController = viewController as? UINavigationController {
            self.currentViewController = navigationController.topViewController
            navigationController.viewControllers.forEach {
                addHook($0)
                if let scene = scene {
                    $0.associate(with: scene)
                }
            }
        } else if let tabBarController = viewController as? UITabBarController {
            self.currentViewController = tabBarController.selectedViewController
            tabBarController.viewControllers?.forEach {
                addHook($0)
                if let scene = scene {
                    $0.associate(with: scene)
                }
            }
        } else {
            self.currentViewController = viewController
        }
        if let currentViewController {
            addHook(currentViewController)
        }
        if let scene = scene {
            viewController.associate(with: scene)
        }
    }

    func associate(with scene: Scened) {
        self.scene = scene
        rootViewController.associate(with: scene)
        currentViewController?.associate(with: scene)
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.viewControllers.forEach {
                $0.associate(with: scene)
            }
        } else if let tabBarController = rootViewController as? UITabBarController {
            tabBarController.viewControllers?.forEach {
                $0.associate(with: scene)
            }
        }
    }
}

extension ViewManager: ViewManagable {
    @inlinable
    public func present(_ viewController: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Present view controller", type(of: viewController))
#endif
        addHook(viewController)
        if let scene = scene {
            viewController.associate(with: scene)
        }
        currentViewController?.present(viewController, animated: true, completion: completion)
    }

    @inlinable
    public func pushViewController(_ viewController: UIViewController, animated flag: Bool) {
#if !RELEASE && !PRODUCTION
        Swift.print("Push view controller", type(of: viewController))
#endif
        addHook(viewController)
        if let scene = scene {
            viewController.associate(with: scene)
        }
        (currentViewController as? UINavigationController ?? currentViewController?.navigationController)?.pushViewController(viewController, animated: true)
    }

    @inlinable
    public func show(_ viewController: UIViewController, sender: Any?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Show view controller", type(of: viewController))
#endif
        addHook(viewController)
        if let scene = scene {
            viewController.associate(with: scene)
        }
        currentViewController?.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss root view controller")
#endif
        rootViewController.internalDismiss(animated: flag, completion: completion)
        scene?.detach()
    }

    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss current view controller")
#endif
        guard let currentViewController else {
            return
        }
        currentViewController.internalDismiss(animated: flag, completion: completion)
        if currentViewController == rootViewController {
            scene?.detach()
        }
    }
}

extension ViewManager {
    @usableFromInline
    func addHook(_ viewController: UIViewController) {
        viewController.whenWillAppear { [weak self] value in
            self?.currentViewController = value
        }

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
        viewController.whenWillDisappear { [weak self] value in
            guard let presentingViewController = value.presentingViewController else { return }
            self?.currentViewController = presentingViewController
        }
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
