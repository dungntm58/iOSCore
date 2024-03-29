//
//  TodoDetailViewController.swift
//  Example
//
//  Created by Robert on 8/27/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import UIKit
import CoreBase

class TodoDetailViewController: UIViewController {
    @IBOutlet weak var lbTitle: UILabel!
    
    @SceneDependencyReferenced var viewManager: ViewManagable?
    @SceneDependencyReferenced var viewModel: TodoStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedIndex = viewModel?.currentState.selectedTodoIndex ?? -1
        lbTitle.text = viewModel?.currentState.list.data[selectedIndex].title
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        viewManager?.dismiss()
    }
}
