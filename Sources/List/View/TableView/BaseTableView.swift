//
//  AppTableView.swift
//  CoreCleanSwiftList
//
//  Created by Robert on 2/12/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

import RxSwift
import DifferenceKit
import CoreCleanSwiftBase
import CoreCleanSwiftRedux

open class BaseTableView: UITableView {
    public typealias DataViewSource = StrictListViewSource & BindableTableViewDataSource & UITableViewDelegate

    public var viewSource: DataViewSource? {
        didSet {
            viewSource?.register(in: self)
        }
    }
}

public extension UITableView {
    func register(cell: CellModel) {
        if cell is HeaderFooterModel {
            switch cell.type {
            case .default:
                register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: cell.reuseIdentifier)
            case .nib(let nibName, let bundle):
                register(UINib(nibName: nibName, bundle: bundle), forHeaderFooterViewReuseIdentifier: cell.reuseIdentifier)
            case .class(let `class`):
                register(`class`, forHeaderFooterViewReuseIdentifier: cell.reuseIdentifier)
            }
        } else {
            switch cell.type {
            case .default:
                register(UITableViewCell.self, forCellReuseIdentifier: cell.reuseIdentifier)
            case .nib(let nibName, let bundle):
                register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: cell.reuseIdentifier)
            case .class(let `class`):
                register(`class`, forCellReuseIdentifier: cell.reuseIdentifier)
            }
        }
    }

    func dequeue<T>(of type: T.Type, fromCellModel cell: CellModel, for indexPath: IndexPath) -> T where T: UITableViewCell {
        switch cell.type {
        case .nib(let nibName, _):
            if String(describing: T.self) != nibName {
                fatalError("Cell nib was not registered")
            }
        case .class(let `class`):
            if T.self != `class`.self {
                fatalError("Cell class was not registered")
            }
        case .default:
            if T.self != UITableViewCell.self {
                fatalError("Cell class must be equal to UITableViewCell")
            }
        }

        return self.dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }

    func dequeue(fromCellModel cell: CellModel, for indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath)
    }

    func dequeue<T>(of type: T.Type, fromHeaderFooterModel cell: HeaderFooterModel) -> T? where T: UITableViewHeaderFooterView {
        switch cell.type {
        case .nib(let nibName, _):
            if String(describing: T.self) != nibName {
                fatalError("Cell nib was not registered")
            }
        case .class(let `class`):
            if T.self != `class`.self {
                fatalError("Cell class was not registered")
            }
        case .default:
            if T.self != UITableViewHeaderFooterView.self {
                fatalError("Cell class must be equal to UITableViewHeaderFooterView")
            }
        }

        return self.dequeueReusableHeaderFooterView(withIdentifier: cell.reuseIdentifier) as? T
    }

    func dequeue(fromHeaderFooterModel cell: HeaderFooterModel) -> UITableViewHeaderFooterView? {
        return self.dequeueReusableHeaderFooterView(withIdentifier: cell.reuseIdentifier)
    }
}
