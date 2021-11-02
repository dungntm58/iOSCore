//
//  UIWindow+Extension.swift
//  CoreBase
//
//  Created by Robert Nguyen on 12/24/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

import UIKit

extension UIWindow {
    @inlinable
    public var topVisibleViewController: UIViewController? {
        var base = rootViewController
        while base != nil {
            if let nav = base as? UINavigationController {
                base = nav.visibleViewController
            } else if let tab = base as? UITabBarController {
                base = tab.selectedViewController
            } else if let presented = base?.presentedViewController {
                base = presented
            } else {
                break
            }
        }
        return base
    }

    @inlinable
    public func getPresentedViewController<T>(of type: T.Type) -> T? where T: UIViewController {
        var base = rootViewController
        while base != nil && !(base is T) {
            if let nav = base as? UINavigationController {
                base = nav.visibleViewController
            } else if let tab = base as? UITabBarController {
                base = tab.selectedViewController
            } else if let presented = base?.presentedViewController {
                base = presented
            } else {
                break
            }
        }
        return base as? T
    }
}
