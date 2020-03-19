//
//  SuperSwitcherViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 12/4/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import RxCoreBase

class SuperSwitcherViewController: UIViewController, SceneBindableRef, ViewManagable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var scene: SwitchScene?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppPreferences.instance.token == nil {
            scene?.switch(to: LoginScene())
        } else {
            scene?.switch(to: TodoScene())
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
