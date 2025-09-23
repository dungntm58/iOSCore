//
//  TodoDetailViewController.swift
//  Example
//
//  Created by Robert on 8/27/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import UIKit
import CoreBase
import CoreMacros
import CoreRedux
import CoreReduxList

@SceneView
class TodoDetailViewController: UIViewController {
    @IBOutlet weak var lbTitle: UILabel!
    
    @SceneDependencyReference var viewManager: ViewManagable?
    @SceneDependencyReference var viewModel: TodoStore?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { @MainActor in
            guard let viewModel = await viewModel else {
                return
            }
            let currentState = viewModel.currentState
            await MainActor.run {
                let selectedIndex = currentState.selectedTodoIndex ?? -1
                lbTitle.text = currentState.list.data[selectedIndex].title
            }
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        Task {
            await viewManager?.dismiss()
        }
    }
}
