//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBase

class SwitchScene: ViewableScene, Launchable {
    lazy var window = UIWindow(frame: UIScreen.main.bounds)
    
    init() {
        let vc = AppStoryboard.main.viewController(of: SuperSwitcherViewController.self)
        vc.modalPresentationStyle = .fullScreen
        super.init(viewManager: vc)
        vc.scene = self
    }

    override func perform(with object: Any?) {
        window.rootViewController = currentViewController
        window.makeKeyAndVisible()
    }
}
