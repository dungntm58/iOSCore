//
//  TodoTabBarController.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import CoreBase
import CoreList
import CoreRedux
import CoreReduxList
#if os(iOS)
import Toaster
#endif

class TodoTabBarController: UITabBarController {
    
    @SceneDependencyReferenced var viewModel: TodoStore?
    @SceneDependencyReferenced var viewManager: TodoScene.ViewManager?
    
    var newTodo: String?
    
    lazy var cancellables: Set<AnyCancellable> = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewTodoAlert))
        let btnLogout = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItems = [btnAdd, btnLogout]
#if os(iOS)
        self.navigationItem.hidesBackButton = true
#endif
        
        viewModel?.state
            .filter { !$0.isLogout }
            .compactMap(\.error)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] error in
                self?.onError(error)
            })
            .store(in: &cancellables)
        
        viewModel?
            .state
            .filter { $0.error == nil && !$0.isLogout }
            .map(\.selectedTodoIndex)
            .filter { $0 >= 0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: {
                [weak self] _ in
                self?.viewManager?.showTodoDetail()
            })
            .store(in: &cancellables)
        
        viewModel?.dispatch(type: .load, payload: Payload.List.Request(page: 1, cancelRunning: false))
    }
    
    @objc func showNewTodoAlert() {
        let vc = UIAlertController(title: "Todo", message: "New Todo", preferredStyle: .alert)
        vc.addTextField {
            [weak self] textField in
            guard let self = self else { return }
            textField
                .publisher(for: \.text)
                .removeDuplicates()
                .assign(to: \.newTodo, on: self)
                .store(in: &self.cancellables)
        }
        vc.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            self.viewModel?.dispatch(type: .createTodo, payload: self.newTodo as Any)
        })
        present(vc, animated: true)
    }
    
    func onError(_ error: Error) {
#if os(iOS)
        Toast(text: error.localizedDescription).show()
#endif
    }
    
    @objc func logout() {
        viewModel?.dispatch(type: .logout, payload: 0)
    }
    
    func showSuccess() {
        let vc = UIAlertController(title: "Todo", message: "Done", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
