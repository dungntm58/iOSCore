//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase

class SwitchScene: Scene, Lauchable, Viewable {
    let viewManager: ViewManager
    let managedContext: ManagedSceneContext
    
    init() {
        managedContext = ManagedSceneContext()
        let vc = AppStoryboard.main.viewController(of: SuperSwitcherViewController.self)
        viewManager = ViewManager(viewController: vc)
        
        vc.scene = self
    }

    func perform() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
