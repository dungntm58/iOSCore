//
//  ViewManager.swift
//  CoreBase
//
//  Created by Robert on 7/21/19.
//

import UIKit
import Combine

open class ViewManager: SceneAssociated {
    private var _currentViewController: UIViewController?
    private var rootViewController: UIViewController
    fileprivate(set) public weak var scene: Scened?

    public init(viewController: UIViewController) {
        _ = UIViewController.swizzle
        self.rootViewController = viewController
        addHook(viewController)
    }

    public func associate(with scene: Scened) {
        self.scene = scene
        ReferenceManager.setScene(scene, associatedViewController: currentViewController)
    }
}

extension ViewManager: ViewManagable {
    private(set) public var currentViewController: UIViewController {
        get { _currentViewController ?? rootViewController }
        set {
            if _currentViewController != nil {
                _currentViewController = newValue
            }
        }
    }

    @inlinable
    public func present(_ viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
#if !RELEASE && !PRODUCTION
        Swift.print("Present view controller", type(of: viewController))
#endif
        addHook(viewController)
        self.currentViewController.present(viewController, animated: true, completion: completion)
    }

    @inlinable
    public func pushViewController(_ viewController: UIViewController, animated flag: Bool = true) {
#if !RELEASE && !PRODUCTION
        Swift.print("Push view controller", type(of: viewController))
#endif
        addHook(viewController)
        (self.currentViewController as? UINavigationController ?? self.currentViewController.navigationController)?.pushViewController(viewController, animated: true)
    }

    @inlinable
    public func show(_ viewController: UIViewController, sender: Any? = nil) {
#if !RELEASE && !PRODUCTION
        Swift.print("Show view controller", type(of: viewController))
#endif
        addHook(viewController)
        self.currentViewController.show(viewController, sender: sender)
    }

    public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss root view controller")
#endif
        internalDismiss(from: rootViewController, animated: flag, completion: completion)
        scene?.detach()
    }
    
    public func goBack(animated flag: Bool = true, completion: (() -> Void)? = nil) {
#if !RELEASE && !PRODUCTION
        Swift.print("Dismiss current view controller")
#endif
        internalDismiss(from: currentViewController, animated: flag, completion: completion)
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

        if let scene = scene {
            ReferenceManager.setScene(scene, associatedViewController: viewController)
        }
    }

    private func addHookViewWillDisappear(_ viewController: UIViewController) {
        viewController.whenWillDisappear { [weak self] value in
            guard let presentingViewController = value.presentingViewController else { return }
            self?._currentViewController = presentingViewController
        }
    }

    @usableFromInline
    func internalDismiss(from viewController: UIViewController, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if let naviViewController = viewController.navigationController {
            if naviViewController.viewControllers.first == viewController {
                naviViewController.dismiss(animated: flag, completion: completion)
            } else if let completion = completion {
                naviViewController.popViewController(animated: true, completion: completion)
            } else {
                naviViewController.popViewController(animated: true)
            }
        } else if let tabbarViewController = viewController.tabBarController {
            tabbarViewController.dismiss(animated: flag, completion: completion)
        } else {
            viewController.dismiss(animated: flag, completion: completion)
        }
    }
}
