//
//  SwitchScene.swift
//  Core-CleanSwift
//
//  Created by Robert Nguyen on 3/24/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CoreBase

class SwitchScene: Scene, Launchable, _HasViewManagable {
    var __viewManager: ViewManagable? { viewManager }
    
    @SceneDependency var viewManager = ViewManager()

    override func perform(with object: Any?) {
        viewManager?.show()
    }
}

extension SwitchScene {
    class ViewManager: CoreBase.ViewManager {
        
        lazy var window = UIWindow(frame: UIScreen.main.bounds)
        
        init() {
            super.init(viewController: {
                let vc = AppStoryboard.main.viewController(of: SuperSwitcherViewController.self)
                vc.modalPresentationStyle = .fullScreen
                return vc
            }())
        }
        
        func show() {
            window.rootViewController = currentViewController
            window.makeKeyAndVisible()
        }
    }
}
