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
    
    @SceneDependencyReferenced var viewManager: ViewManagable?
    @SceneDependencyReferenced var viewModel: TodoViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbTitle.text = viewModel?.selectedTodo?.title
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        viewManager?.dismiss()
    }
}
