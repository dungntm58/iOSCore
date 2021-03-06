//
//  AnyTableViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

extension TableView {
    public struct AnyHeaderFooter: TableViewHeaderFooter {
        public typealias View = UITableViewHeaderFooterView

        fileprivate let box: AnyTableViewHeaderFooterBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: TableViewHeaderFooter {
            if let _cell = cell as? AnyHeaderFooter {
                self = _cell
            } else {
                box = HeaderFooterBox(cell)
            }
        }

        public var type: CellType { box.type }
        public var reuseIdentifier: String { box.reuseIdentifier }
        public var position: HeaderFooterPosition { box.position }
        public var height: CGFloat { box.height }
        public var title: String? { box.title }
        public var model: Any? { box.model }

        public func bind(model: Any?, to view: View, at section: Int) {
            box.bind(model: model, to: view, at: section)
        }

        public func willDisplay(view: View, at section: Int) {
            box.willDisplay(view: view, at: section)
        }

        public func didEndDisplaying(view: View, at section: Int) {
            box.didEndDisplaying(view: view, at: section)
        }

        @inlinable
        public static var none: AnyHeaderFooter? { nil }
    }
}

extension TableView.AnyHeaderFooter: Equatable {
    @inlinable
    public static func == (lhs: TableView.AnyHeaderFooter, rhs: TableView.AnyHeaderFooter) -> Bool {
        lhs.reuseIdentifier == rhs.reuseIdentifier
            && lhs.height == rhs.height
            && lhs.title == rhs.title
    }
}

private protocol AnyTableViewHeaderFooterBox {
    var type: CellType { get }
    var reuseIdentifier: String { get }
    var position: HeaderFooterPosition { get }
    var height: CGFloat { get }
    var title: String? { get }
    var model: Any? { get }

    func bind(model: Any?, to view: UITableViewHeaderFooterView, at section: Int)
    func willDisplay(view: UITableViewHeaderFooterView, at section: Int)
    func didEndDisplaying(view: UITableViewHeaderFooterView, at section: Int)
}

private extension TableView.AnyHeaderFooter {
    struct HeaderFooterBox<Base>: AnyTableViewHeaderFooterBox where Base: TableViewHeaderFooter {
        @usableFromInline
        let _base: Base

        @usableFromInline
        init(_ base: Base) {
            self._base = base
        }
        
        @inlinable
        var type: CellType { _base.type }

        @inlinable
        var reuseIdentifier: String { _base.reuseIdentifier }

        @inlinable
        var position: HeaderFooterPosition { _base.position }

        @inlinable
        var height: CGFloat { _base.height }

        @inlinable
        var title: String? { _base.title }

        @inlinable
        var model: Any? { _base.model }

        @inlinable
        func bind(model: Any?, to view: UITableViewHeaderFooterView, at section: Int) {
            guard let view = view as? Base.View else {
                preconditionFailure("Opaque cell must associate with view type \(String(describing: Base.View.self))")
            }
            _base.bind(model: model as? Base.Model, to: view, at: section)
        }

        @inlinable
        func willDisplay(view: UITableViewHeaderFooterView, at section: Int) {
            _base.willDisplay(view: view as! Base.View, at: section)
        }

        @inlinable
        func didEndDisplaying(view: UITableViewHeaderFooterView, at section: Int) {
            _base.didEndDisplaying(view: view as! Base.View, at: section)
        }
    }
}
