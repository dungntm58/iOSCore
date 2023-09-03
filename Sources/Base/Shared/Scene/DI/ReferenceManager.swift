//
//  ReferenceManager.swift
//  CoreBase
//
//  Created by Dung Nguyen on 7/7/20.
//

import Foundation
import UIKit

extension UIViewController: SceneAssociated {
    @usableFromInline
    func associate(with scene: Scened) {
        objc_setAssociatedObject(self, &Keys.associatedScene, scene, .OBJC_ASSOCIATION_ASSIGN)
    }

    var scene: Scened? {
        objc_getAssociatedObject(self, &Keys.associatedScene) as? Scened
    }
}

private extension UIViewController {
    enum Keys {
        static var associatedScene: UInt8 = 0
    }
}
