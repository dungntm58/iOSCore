//
//  ViewProtocols.swift
//  CoreMacroProtocols
//
//  View management protocols and extensions
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - View Management Protocols

/// Generic view representation that can be any displayable content
@MainActor
public protocol ViewRepresentable {
#if canImport(UIKit)
    /// Convert to UIViewController for UIKit presentation
    func asViewController() -> UIViewController
#endif
}

#if canImport(UIKit)
/// Extension to make UIViewController conform to ViewRepresentable
extension UIViewController: ViewRepresentable {
    public func asViewController() -> UIViewController {
        return self
    }
}
#endif

/// Extension to make SwiftUI View conform to ViewRepresentable
#if canImport(SwiftUI) && canImport(UIKit)
@available(iOS 13.0, macOS 10.15, *)
extension View {
    public func asViewController() -> UIViewController {
        return UIHostingController(rootView: self)
    }
}
#endif

/// Protocol for types that have view management capabilities
@MainActor
public protocol HasViewManagable {
    var anyViewManager: ViewManagable? { get }
}

/// Protocol for view management
@MainActor
public protocol ViewManagable {
#if canImport(UIKit)
    /// The current view controller that scene presents (for legacy compatibility)
    var currentViewController: UIViewController? { get }
#endif

    /// Present any view representable content
    func present<V: ViewRepresentable>(_ view: V, animated flag: Bool, completion: (() -> Void)?)

    /// Push any view representable content to navigation stack
    func push<V: ViewRepresentable>(_ view: V, animated flag: Bool)

    /// Show any view representable content
    func show<V: ViewRepresentable>(_ view: V, sender: Any?)

    /// Back to previous view
    func goBack(animated flag: Bool, completion: (() -> Void)?)

    /// Dismiss the root view
    func dismiss(animated flag: Bool, completion: (() -> Void)?)

    /// Present another view manager
    func present(_ viewManager: ViewManagable, animated flag: Bool, completion: (() -> Void)?)

    /// Push another view manager to navigation stack
    func push(_ viewManager: ViewManagable, animated flag: Bool)

    /// Show another view manager
    func show(_ viewManager: ViewManagable, sender: Any?)
}

extension ViewManagable {

    // MARK: - Generic View Convenience Methods

    @inlinable
    public func present<V: ViewRepresentable>(_ view: V, animated flag: Bool) {
        present(view, animated: flag, completion: nil)
    }

    @inlinable
    public func present<V: ViewRepresentable>(_ view: V) {
        present(view, animated: true, completion: nil)
    }

    @inlinable
    public func push<V: ViewRepresentable>(_ view: V) {
        push(view, animated: true)
    }

    @inlinable
    public func show<V: ViewRepresentable>(_ view: V) {
        show(view, sender: nil)
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
    public func present(_ viewManager: ViewManagable, animated flag: Bool) {
        present(viewManager, animated: flag, completion: nil)
    }

    @inlinable
    public func push(_ viewManager: ViewManagable) {
        push(viewManager, animated: true)
    }

    @inlinable
    public func show(_ viewManager: ViewManagable) {
        show(viewManager, sender: nil)
    }

#if canImport(UIKit)
    // MARK: - Default Implementations

    /// Default implementation for presenting views - converts to UIViewController
    public func present<V: ViewRepresentable>(_ view: V, animated flag: Bool, completion: (() -> Void)?) {
        let viewController = view.asViewController()
        currentViewController?.present(viewController, animated: flag, completion: completion)
    }

    /// Default implementation for pushing views - converts to UIViewController
    public func push<V: ViewRepresentable>(_ view: V, animated flag: Bool) {
        let viewController = view.asViewController()
        currentViewController?.navigationController?.pushViewController(viewController, animated: flag)
    }

    /// Default implementation for showing views - converts to UIViewController
    public func show<V: ViewRepresentable>(_ view: V, sender: Any?) {
        let viewController = view.asViewController()
        currentViewController?.show(viewController, sender: sender)
    }

    /// Default implementation for presenting view managers
    public func present(_ viewManager: ViewManagable, animated flag: Bool, completion: (() -> Void)?) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.present(destinationViewController, animated: flag, completion: completion)
    }

    /// Default implementation for pushing view managers
    public func push(_ viewManager: ViewManagable, animated flag: Bool) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.navigationController?.pushViewController(destinationViewController, animated: flag)
    }

    /// Default implementation for showing view managers
    public func show(_ viewManager: ViewManagable, sender: Any?) {
        guard let destinationViewController = viewManager.currentViewController else {
            return
        }
        currentViewController?.show(destinationViewController, sender: sender)
    }
#endif
}

#if canImport(UIKit)
extension ViewManagable where Self: UIViewController {

    @inlinable
    public var currentViewController: UIViewController? { self }

    @inlinable
    public func push<V: ViewRepresentable>(_ view: V, animated flag: Bool) {
        let viewController = view.asViewController()
        (self as? UINavigationController ?? navigationController)?.pushViewController(viewController, animated: flag)
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

extension UINavigationController {

    @discardableResult
    @inlinable
    public func popViewController(animated: Bool, completion: (() -> Void)?) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let viewController = self.popViewController(animated: animated)
        CATransaction.commit()
        CATransaction.setCompletionBlock(nil)
        return viewController
    }

}
#endif
