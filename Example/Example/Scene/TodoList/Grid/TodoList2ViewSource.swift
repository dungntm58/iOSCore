//
//  Todo2ViewSource.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase
import RxCoreList
import RxCoreRedux
import RxCoreRepository
import DifferenceKit

class TodoList2ViewSource: BaseCollectionViewSource, UICollectionViewDelegateFlowLayout {
    weak var store: TodoStore?
    
    init(store: TodoStore?) {
        self.store = store
        let cell = CellModelType.nib(nibName: "TodoCollectionViewCell", bundle: nil).makeCell()
        super.init(sections: [[cell].makeSection()], shouldAnimateLoading: true)
        
        let response = store?.state
            .filter { $0.error == nil && !$0.isLogout }
            .map { $0.list }
            .distinctUntilChanged()
            .share()
        
        response?
            .map { $0.hasNext }
            .distinctUntilChanged()
            .bind(to: rx.isAnimating)
            .disposed(by: disposeBag)
        
        response?
            .filter { !$0.isLoading }
            .map {
                response in
                if response.currentPage <= 1 {
                    return ListViewSourceModel(type: .initial, data: response.data, needsReload: true)
                } else {
                    return ListViewSourceModel(type: .addNew(at: .end(length: response.data.count)), data: response.data, needsReload: true)
                }
            }
            .bind(to: rx.model)
            .disposed(by: disposeBag)
    }
    
    override func bind(value: ViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoCollectionViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        store?.dispatch(type: .selectTodo, payload: indexPath.row)
    }
    
    override func reachToEnd() {
        let currentPage = store?.currentState.list.currentPage ?? 0
        store?.dispatch(type: .load, payload: Payload.List.Request(page: currentPage + 1, cancelRunning: false))
    }
}
