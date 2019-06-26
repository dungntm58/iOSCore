//
//  Core-CleanSwift-ExampleViewModel.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/13/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase
import CoreList
import DifferenceKit

class TodoListViewSource: BaseTableViewSource {
    init(store: TodoStore?) {
        let cell = DefaultCellModel(type: .nib(nibName: "TodoTableViewCell", bundle: nil))
        cell.height = 80
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
    
    override func bind(value: CleanViewModelItem, to cell: UITableViewCell, at indexPath: IndexPath) {
        let item = value as! TodoEntity
        let dataCell = cell as! TodoTableViewCell
        
        dataCell.lbTime.text = item.createdAt.toISO()
        dataCell.lbTitle.text = item.title
    }
    
    override func objects(in section: SectionModel, at index: Int, onChanged type: ListModelChangeType) -> [AnyDifferentiable] {
        if let models = models(forIdentifier: "default") {
            return models.map { $0.toAnyDifferentiable() }
        }
        
        return super.objects(in: section, at: index, onChanged: type)
    }
}
