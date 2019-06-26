//
//  UIView+Extension.swift
//  Alamofire
//
//  Created by Robert Nguyen on 3/31/19.
//

public extension UIView {
    func sendSelfBackToSuperview() {
        self.superview?.sendSubviewToBack(self)
    }

    func bringSelfToFrontSuperview() {
        self.superview?.bringSubviewToFront(self)
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
