//
//  UIViewController_swizzle.swift
//  CoreBase-Combine
//
//  Created by Robert on 14/10/2021.
//

import UIKit

extension UIViewController {
    private enum Key {
        static var viewWillAppear: UInt8 = 0
        static var viewWillDisappear: UInt8 = 1
    }

    private class ClosureHandler {
        weak var associatedValue: UIViewController?
        let handler: (UIViewController) -> Void

        init(associatedValue: UIViewController?, handler: @escaping (UIViewController) -> Void) {
            self.associatedValue = associatedValue
            self.handler = handler
        }

        func execute() {
            guard let associatedValue = associatedValue else {
                return
            }
            handler(associatedValue)
        }
    }

    static var swizzle: () = {
        func swizzleSelector(origin: Selector, target: Selector) {
            let `class` = UIViewController.self
            guard let originalMethod = class_getInstanceMethod(`class`, origin),
                  let swizzledMethod = class_getInstanceMethod(`class`, target) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        swizzleSelector(origin: #selector(viewWillAppear(_:)), target: #selector(swizzle_viewWillAppear(_:)))
        swizzleSelector(origin: #selector(viewWillDisappear(_:)), target: #selector(swizzle_viewWillDisappear(_:)))
    }()

    @objc func swizzle_viewWillAppear(_ animated: Bool) {
        swizzle_viewWillAppear(animated)
        guard let handler = objc_getAssociatedObject(self, &Key.viewWillAppear) as? ClosureHandler else { return }
        handler.execute()
    }

    @objc func swizzle_viewWillDisappear(_ animated: Bool) {
        swizzle_viewWillDisappear(animated)
        guard let handler = objc_getAssociatedObject(self, &Key.viewWillDisappear) as? ClosureHandler else { return }
        handler.execute()
    }

    func whenWillAppear(_ handler: @escaping (UIViewController) -> Void) {
        objc_setAssociatedObject(self, &Key.viewWillAppear, ClosureHandler(associatedValue: self, handler: handler), .OBJC_ASSOCIATION_RETAIN)
    }

    func whenWillDisappear(_ handler: @escaping (UIViewController) -> Void) {
        objc_setAssociatedObject(self, &Key.viewWillDisappear, ClosureHandler(associatedValue: self, handler: handler), .OBJC_ASSOCIATION_RETAIN)
    }
}
