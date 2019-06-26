//
//  LoginRouter.swift
//  Core-CleanSwift_Example_Realm
//
//  Created by Robert Nguyen on 3/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase

class LoginScene: Scene, Viewable {
    let viewManager: ViewManager
    let managedContext: ManagedSceneContext
    
    init() {
        managedContext = ManagedSceneContext()
        viewManager = ViewManager(viewController: AppStoryboard.main.viewController(of: SuperSwitcherViewController.self))
    }
    
    func perform() {
        if let navigationController = nearestViewableScene?.viewController.navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            nearestViewableScene?.viewController.present(viewController, animated: true)
        }
    }
}
