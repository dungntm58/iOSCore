//
//  UINavigationController+.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/2/20.
//

import UIKit

extension UINavigationController {

    @discardableResult
    public func popViewController(animated: Bool, completion: (() -> Void)?) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let viewController = self.popViewController(animated: animated)
        CATransaction.commit()
        CATransaction.setCompletionBlock(nil)
        return viewController
    }

}

extension UIViewController {

    public func dismissKeyboard() {
        view.endEditing(true)
    }

    public func canPerformSegue(withIdentifier identifier: String) -> Bool {
        guard let segueTemplates = value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
        return segueTemplates.contains { $0.value(forKey: "_identifier") as? String == identifier }
    }

}
