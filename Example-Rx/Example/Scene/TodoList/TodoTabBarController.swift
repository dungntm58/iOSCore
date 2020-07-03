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

class TodoTabBarController: UITabBarController, ConnectedSceneBindableRef {
    
    var scene: TodoScene?
    var newTodo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewTodoAlert))
        let btnLogout = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItems = [btnAdd, btnLogout]
        self.navigationItem.hidesBackButton = true
        
        let store = self.scene?.store
        store?.state
            .filter { !$0.isLogout }
            .compactMap(\.error)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] error in
                self?.onError(error)
            })
            .disposed(by: rx.disposeBag)
        
        store?
            .state
            .filter { $0.error == nil }
            .map(\.isLogout)
            .filter { $0 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.detach(with: nil)
            })
            .disposed(by: rx.disposeBag)
        
        store?
            .state
            .filter { $0.error == nil && !$0.isLogout }
            .map(\.selectedTodoIndex)
            .filter { $0 >= 0 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: {
                [weak self] _ in
                self?.scene?.showTodoDetail()
            })
            .disposed(by: rx.disposeBag)
        
        store?.dispatch(type: .load, payload: Payload.List.Request(page: 1, cancelRunning: false))
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
                .subscribe(onNext: {
                    [weak self] value in
                    self?.newTodo = value
                })
                .disposed(by: self.rx.disposeBag)
        }
        vc.addAction(UIAlertAction(title: "OK", style: .default) {
            _ in
            self.scene?.dispatch(type: .createTodo, payload: self.newTodo as Any)
        })
        present(vc, animated: true)
    }
    
    func onError(_ error: Error) {
        Toast(text: error.localizedDescription).show()
    }
    
    @objc func logout() {
        scene?.store.dispatch(type: .logout, payload: 0)
    }
    
    func showSuccess() {
        let vc = UIAlertController(title: "Todo", message: "Done", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
