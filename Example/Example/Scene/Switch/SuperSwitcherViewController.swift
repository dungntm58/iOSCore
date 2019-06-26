//
//  SuperSwitcherViewController.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 12/4/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit

class SuperSwitcherViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    weak var scene: SwitchScene?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppPreferences.instance.token == nil {
            scene?.navigate(to: LoginScene())
        } else {
            scene?.navigate(to: TodoScene())
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
