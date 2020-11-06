//
//  TodoGridScene.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreBase
import CoreRedux

class TodoGridScene: Scene {
    
    @SceneDependency var store = TodoGridStore()
    @SceneDependency var viewManager = ViewManager()
    
    override func perform(with userInfo: Any?) {
        viewManager?.show()
    }
}

extension TodoGridScene {
    class ViewManager: CoreBase.ViewManager {
        init() {
            super.init(viewController: {
                let vc = AppStoryboard.main.viewController(of: TodoList2ViewController.self)
                return vc
            }())
        }
        
        func show() {
            currentViewController.tabBarController?.selectedIndex = 1
        }
    }
}
