//
//  TodoDetailViewController.swift
//  Example
//
//  Created by Robert on 8/27/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import CoreBase

class TodoDetailViewController: UIViewController {
    @IBOutlet weak var lbTitle: UILabel!
    
    @SceneReferenced var scene: TodoScene?
    @SceneDependencyReferenced var store: TodoStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbTitle.text = store?.currentState.selectedTodo?.title
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        scene?.detach(with: nil)
    }
}
