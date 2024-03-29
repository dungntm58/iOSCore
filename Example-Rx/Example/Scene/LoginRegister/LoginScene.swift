//
//  LoginRouter.swift
//  Core-CleanSwift_Example_Realm
//
//  Created by Robert Nguyen on 3/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase

protocol LoginSceneProtocol: Scened {
    var store: LoginStore? { get }
}

class LoginScene: Scene, LoginSceneProtocol, _HasViewManagable {
    var __viewManager: ViewManagable? { viewManager }
    
    @SceneDependency var store = LoginStore()
    @SceneDependency var viewManager = ViewManager()
    
    override func perform(with object: Any?) {
        viewManager?.show()
    }
}

extension LoginScene {
    class ViewManager: CoreBase.ViewManager {
        init() {
            super.init(viewController: {
                let vc = AppStoryboard.main.viewController(of: LoginViewController.self)
                vc.modalPresentationStyle = .fullScreen
                return vc
            }())
        }
        
        func show() {
            if let navigationController = scene?.presentedViewManager?.currentViewController?.navigationController, let currentViewController {
                navigationController.pushViewController(currentViewController, animated: true)
            } else if let currentViewController {
                scene?.presentedViewManager?.currentViewController?.present(currentViewController, animated: true)
            }
        }
    }
}
