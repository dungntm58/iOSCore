//
//  SuperSwitcherViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 12/4/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import CoreBase

class SuperSwitcherViewController: UIViewController, ViewManagable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @SceneReferenced var scene: SwitchScene?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppPreferences.instance.token == nil {
            scene?.switch(to: LoginScene(), with: nil)
        } else {
            scene?.switch(to: TodoScene(), with: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
