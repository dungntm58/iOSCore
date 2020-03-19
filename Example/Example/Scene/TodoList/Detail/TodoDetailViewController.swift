//
//  TodoDetailViewController.swift
//  Example
//
//  Created by Robert on 8/27/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxCoreBase

class TodoDetailViewController: UIViewController, ConnectedSceneBindableRef {
    @IBOutlet weak var lbTitle: UILabel!
    
    var scene: TodoScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedIndex = scene?.store.currentState.selectedTodoIndex ?? -1
        lbTitle.text = scene?.store.currentState.list.data[selectedIndex].title
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        scene?.goBack()
    }
}
