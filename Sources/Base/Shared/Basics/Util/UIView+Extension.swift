//
//  UIView+Extension.swift
//  CoreBase
//
//  Created by Robert Nguyen on 3/31/19.
//

import UIKit

extension UIView {
    @inlinable
    public func sendSelfBackToSuperview() {
        superview?.sendSubviewToBack(self)
    }

    @inlinable
    public func bringSelfToFrontSuperview() {
        superview?.bringSubviewToFront(self)
    }

    @inlinable
    public var viewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
