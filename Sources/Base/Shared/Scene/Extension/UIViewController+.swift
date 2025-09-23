//
//  UINavigationController+.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/2/20.
//

import UIKit

extension UIViewController {

    @inlinable
    public func dismissKeyboard() {
        view.endEditing(true)
    }

    @inlinable
    public func canPerformSegue(withIdentifier identifier: String) -> Bool {
        guard let segueTemplates = value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
        return segueTemplates.contains { $0.value(forKey: "_identifier") as? String == identifier }
    }

}
