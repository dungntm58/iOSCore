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
import Toaster

class TodoTabBarController: UITabBarController {
    private lazy var disposeBag = DisposeBag()
    
    weak var scene: TodoScene?
    var newTodo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showNewTodoAlert))
        self.navigationItem.rightBarButtonItem = btnAdd
        self.navigationItem.hidesBackButton = true
        
        let store = self.scene?.store
        store?.state
            .compactMap { $0.error.error }
            .subscribe(onNext: onError)
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scene?.dispatch(type: .load, payload: Payload.List.Request(page: 1, cancelRunning: false))
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
                .disposed(by: self.disposeBag)
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
    
    func showSuccess() {
        let vc = UIAlertController(title: "Todo", message: "Done", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default))
        present(vc, animated: true)
    }
}
