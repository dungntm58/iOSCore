//
//  Todo2ViewSource.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/23/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreList
import CoreRequest
import DifferenceKit

class TodoList2ViewSource: BaseCollectionViewSource, UICollectionViewDelegateFlowLayout {
    init(store: TodoStore?) {
        let cell = DefaultCellModel(type: .nib(nibName: "TodoCollectionViewCell", bundle: nil))
        let sectionModels: [DefaultSectionModel] = [
            .init(cells: [ cell ])
        ]
        super.init(sections: sectionModels, shouldAnimateLoading: true)
        
        store?.state
            .filter { $0.error.error == nil }
            .map { $0.list }
            .distinctUntilChanged()
            .map {
                response in
                if response.currentPage == 0 {
                    return ListViewSourceModel(type: .initial, data: response.data, needsReload: true)
                } else {
                    return ListViewSourceModel(type: .addNew(at: .end(length: response.data.count)), data: response.data, needsReload: true)
                }
            }
            .bind(to: modelRelay)
            .disposed(by: disposeBag)
    }
    
    override func bind(value: CleanViewModelItem, to cell: UICollectionViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoCollectionViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    override func objects(in section: SectionModel, at index: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        if let models = models(forIdentifier: "default") {
            return models.map { $0.toAnyDifferentiable() }
        }
        
        return super.objects(in: section, at: index, onChanged: type)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}
