//
//  UITableView+.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import UIKit

extension UITableView {
    @inlinable
    public func register<Cell>(cell: Cell) where Cell: TableViewCell {
        switch cell.type {
        case .default:
            register(UITableViewCell.self, forCellReuseIdentifier: cell.reuseIdentifier)
        case .nib(let nibName, let bundle):
            register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: cell.reuseIdentifier)
        case .class(let `class`):
            register(`class`, forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }

    @inlinable
    public func register<HeaderFooter>(headerFooter: HeaderFooter) where HeaderFooter: TableViewHeaderFooter {
        switch headerFooter.type {
        case .default:
            register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerFooter.reuseIdentifier)
        case .nib(let nibName, let bundle):
            register(UINib(nibName: nibName, bundle: bundle), forHeaderFooterViewReuseIdentifier: headerFooter.reuseIdentifier)
        case .class(let `class`):
            register(`class`, forHeaderFooterViewReuseIdentifier: headerFooter.reuseIdentifier)
        }
    }

    // swiftlint:disable force_cast
    @inlinable
    public func dequeue<T, Cell>(of type: T.Type, cell: Cell, for indexPath: IndexPath) -> T where T: UITableViewCell, Cell: TableViewCell {
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
    // swiftlint:enable force_cast

    @inlinable
    public func dequeue<Cell>(cell: Cell, for indexPath: IndexPath) -> UITableViewCell where Cell: TableViewCell {
        dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath)
    }

    @inlinable
    func dequeue<Cell>(cell: Cell) -> UITableViewCell? where Cell: TableViewCell {
        dequeueReusableCell(withIdentifier: cell.reuseIdentifier)
    }

    @inlinable
    public func dequeue<T, HeaderFooter>(of type: T.Type, headerFooter: HeaderFooter) -> T? where T: UITableViewHeaderFooterView, HeaderFooter: TableViewHeaderFooter {
        switch headerFooter.type {
        case .nib(let nibName, _):
            precondition(String(describing: T.self) != nibName, "Header footer nib was not registered")
        case .class(let `class`):
            precondition(T.self != `class`.self, "Header footer class was not registered")
        case .default:
            precondition(T.self != UICollectionViewCell.self, "Header footer class must be equal to UITableViewHeaderFooterView")
        }
        return dequeueReusableHeaderFooterView(withIdentifier: headerFooter.reuseIdentifier) as? T
    }

    @inlinable
    public func dequeue<HeaderFooter>(headerFooter: HeaderFooter) -> UITableViewHeaderFooterView? where HeaderFooter: TableViewHeaderFooter {
        dequeueReusableHeaderFooterView(withIdentifier: headerFooter.reuseIdentifier)
    }

    @inlinable
    static public var leastNonzeroOfGroupedHeaderFooterHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return 0.01
        } else {
            return 1.01
        }
    }

    @inlinable
    public var leastOfHeaderFooterHeight: CGFloat {
        style == .plain ? 0 : UITableView.leastNonzeroOfGroupedHeaderFooterHeight
    }
}
