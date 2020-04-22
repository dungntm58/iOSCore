//
//  UIView+Extension.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 3/31/19.
//

public extension UIView {
    func sendSelfBackToSuperview() {
        superview?.sendSubviewToBack(self)
    }

    func bringSelfToFrontSuperview() {
        superview?.bringSubviewToFront(self)
    }

    var viewController: UIViewController? {
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
