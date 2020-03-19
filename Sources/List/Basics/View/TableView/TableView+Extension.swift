//
//  TableView+Extension.swift
//  RxCoreList
//
//  Created by Robert on 8/10/19.
//

public extension UITableView {
    static var leastNonzeroOfGroupedHeaderFooterHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return 0.01
        } else {
            return 1.01
        }
    }

    var leastOfHeaderFooterHeight: CGFloat {
        style == .plain ? 0 : UITableView.leastNonzeroOfGroupedHeaderFooterHeight
    }

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
            precondition(String(describing: T.self) != nibName, "Cell nib was not registered")
        case .class(let `class`):
            precondition(T.self != `class`.self, "Cell class was not registered")
        case .default:
            precondition(T.self != UICollectionViewCell.self, "Cell class must be equal to UITableViewCell")
        }
        return dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath) as! T
    }

    func dequeue(fromCellModel cell: CellModel, for indexPath: IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath)
    }

    func dequeue<T>(of type: T.Type, fromHeaderFooterModel cell: HeaderFooterModel) -> T? where T: UITableViewHeaderFooterView {
        switch cell.type {
        case .nib(let nibName, _):
            precondition(String(describing: T.self) != nibName, "Header footer nib was not registered")
        case .class(let `class`):
            precondition(T.self != `class`.self, "Header footer class was not registered")
        case .default:
            precondition(T.self != UICollectionViewCell.self, "Header footer class must be equal to UITableViewHeaderFooterView")
        }
        return dequeueReusableHeaderFooterView(withIdentifier: cell.reuseIdentifier) as? T
    }

    func dequeue(fromHeaderFooterModel cell: HeaderFooterModel) -> UITableViewHeaderFooterView? {
        dequeueReusableHeaderFooterView(withIdentifier: cell.reuseIdentifier)
    }
}
