//
//  ReferenceManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation
import UIKit

extension UIViewController: SceneAssociated {
    public func associate(with scene: Scened) {
        self.scene = scene
    }

    private(set) public var scene: Scened? {
        get {
            objc_getAssociatedObject(self, &Keys.associatedScene) as? Scened
        }
        set {
            if self.scene != nil {
                return
            }
            objc_setAssociatedObject(self, &Keys.associatedScene, newValue, .OBJC_ASSOCIATION_ASSIGN)
            pureSetSceneTopDown(newValue)
            pureSetSceneBottomUp(newValue)
        }
    }
}

private extension UIViewController {
    enum Keys {
        static var associatedScene: UInt8 = 0
    }

    func pureSetSceneBottomUp(_ scene: Scened?) {
        if let presentingViewController = presentingViewController {
            presentingViewController.scene = scene
        }
        if let tabBarController = tabBarController {
            tabBarController.scene = scene
            tabBarController.viewControllers?.filter { $0 !== self }.forEach {
                $0.scene = scene
            }
        } else if let navigationController = navigationController {
            navigationController.scene = scene
            navigationController.viewControllers.filter { $0 !== self }.forEach {
                $0.scene = scene
            }
        } else if let splitController = splitViewController {
            splitController.scene = scene
            splitController.viewControllers.filter { $0 !== self }.forEach {
                $0.scene = scene
            }
        }
    }

    func pureSetSceneTopDown(_ scene: Scened?) {
        if let presentedViewController = presentedViewController {
            presentedViewController.scene = scene
        }
        if let tabBarController = self as? UITabBarController {
            tabBarController.viewControllers?.forEach {
                $0.scene = scene
            }
        } else if let navigationController = self as? UINavigationController {
            navigationController.viewControllers.forEach {
                $0.scene = scene
            }
        } else if let splitController = self.splitViewController {
            splitController.viewControllers.forEach {
                $0.scene = scene
            }
        }
    }
}
