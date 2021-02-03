//
//  TodoTabBarController.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 2/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxCocoa
import RxSwift
import CoreBase
import CoreList
import CoreRedux
import Toaster

class TodoTabBarController: UITabBarController {
    
    @SceneReferenced var scene: Scenable?
    @SceneDependencyReferenced var store: TodoStore?
    @SceneDependencyReferenced var viewManager: TodoScene.ViewManager?
    
    var newTodo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewTodoAlert))
        let btnLogout = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItems = [btnAdd, btnLogout]
        self.navigationItem.hidesBackButton = true
        
        store?.state
            .filter { !$0.isLogout }
            .compactMap(\.error)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { $0.onError($1) })
            .disposed(by: rx.disposeBag)
        
        store?
            .state
            .filter { $0.error == nil }
            .map(\.isLogout)
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: {
                `self`, _ in
                self.scene?.detach(with: nil)
            })
            .disposed(by: rx.disposeBag)
        
        store?
            .state
            .filter { $0.error == nil && !$0.isLogout }
            .compactMap(\.selectedTodo)
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: {
                `self`, _ in
                self.viewManager?.showTodoDetail()
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc func showNewTodoAlert() {
        let vc = UIAlertController(title: "Todo", message: "New Todo", preferredStyle: .alert)
        vc.addTextField {
            [weak self] textField in
            guard let `self` = self else { return }
            textField
                .rx
                .text
                .orEmpty
                .distinctUntilChanged()
                .bind(to: self.rx.newTodo)
                .disposed(by: self.rx.disposeBag)
        }
        vc.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            self.store?.dispatch(type: .createTodo, payload: self.newTodo)
        })
        present(vc, animated: true)
    }
    
    func onError(_ error: Error) {
        Toast(text: error.localizedDescription).show()
    }
    
    @objc func logout() {
        self.store?.dispatch(type: .logout)
    }
    
    func showSuccess() {
        let vc = UIAlertController(title: "Todo", message: "Done", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
