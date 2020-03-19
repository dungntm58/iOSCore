//
//  LoginRouter.swift
//  Core-CleanSwift_Example_Realm
//
//  Created by Robert Nguyen on 3/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxCoreBase

class LoginScene: ConnectableViewableScene<LoginStore> {
    convenience init() {
        let vc = AppStoryboard.main.viewController(of: LoginViewController.self)
        vc.modalPresentationStyle = .fullScreen
        self.init(store: LoginStore(), viewController: vc)
    }
    
    override func perform() {
        if let navigationController = nearestViewable?.currentViewController.navigationController {
            navigationController.pushViewController(currentViewController, animated: true)
        } else {
            nearestViewable?.currentViewController.present(currentViewController, animated: true)
        }
    }
}
