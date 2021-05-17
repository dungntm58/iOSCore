//
//  AnyTableViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import FoundationExt_R

extension TableView {
    public struct AnyCell: TableViewCell, CellInteractable {
        public typealias ID = AnyHashable
        public typealias Model = AnyEquatable
        public typealias View = UITableViewCell

        private let box: AnyTableViewCellBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: TableViewCell {
            if let instance = cell as? AnyCell {
                self = instance
            } else {
                box = CellBox(cell)
            }
        }

        public var id: AnyHashable { box.id }
        public var type: CellType { box.type }
        public var reuseIdentifier: String { box.reuseIdentifier }
        public var height: CGFloat { box.height }
        public var model: AnyEquatable? { box.model }

        public func bind(model: AnyEquatable?, to view: View, at indexPath: IndexPath) {
            box.bind(model: model?.base, to: view, at: indexPath)
        }

        public func willDisplay(view: View, at indexPath: IndexPath) {
            box.willDisplay(view: view, at: indexPath)
        }

        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            box.didEndDisplaying(view: view, at: indexPath)
        }

        public func didSelect(at indexPath: IndexPath) {
            box.didSelect(at: indexPath)
        }

        public func didDeselect(at indexPath: IndexPath) {
            box.didDeselect(at: indexPath)
        }
    }
}

private protocol AnyTableViewCellBox: CellInteractable {
    var id: AnyHashable { get }
    var type: CellType { get }
    var reuseIdentifier: String { get }
    var height: CGFloat { get }
    var model: AnyEquatable? { get }

    func bind(model: Any?, to view: UITableViewCell, at indexPath: IndexPath)
    func willDisplay(view: UITableViewCell, at indexPath: IndexPath)
    func didEndDisplaying(view: UITableViewCell, at indexPath: IndexPath)
}

private extension TableView.AnyCell {
    struct CellBox<Base>: AnyTableViewCellBox where Base: TableViewCell {
        @usableFromInline
        let _base: Base

        @inlinable
        init(_ base: Base) {
            self._base = base
        }

        @inlinable
        var id: AnyHashable { _base.id }

        @inlinable
        var type: CellType { _base.type }

        @inlinable
        var reuseIdentifier: String { _base.reuseIdentifier }

        @inlinable
        var height: CGFloat { _base.height }

        @inlinable
        var model: AnyEquatable? { _base.model?.eraseToAny() }

        @inlinable
        func bind(model: Any?, to view: UITableViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else {
                preconditionFailure("Opaque cell must associate with view type \(String(describing: Base.View.self))")
            }
            _base.bind(model: model as? Base.Model, to: view, at: indexPath)
        }

        @inlinable
        func willDisplay(view: UITableViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.willDisplay(view: view, at: indexPath)
        }

        @inlinable
        func didEndDisplaying(view: UITableViewCell, at indexPath: IndexPath) {
            guard let view = view as? Base.View else { return }
            _base.didEndDisplaying(view: view, at: indexPath)
        }

        @inlinable
        func didSelect(at indexPath: IndexPath) {
            (_base as? CellInteractable)?.didSelect(at: indexPath)
        }

        @inlinable
        func didDeselect(at indexPath: IndexPath) {
            (_base as? CellInteractable)?.didDeselect(at: indexPath)
        }
    }
}
