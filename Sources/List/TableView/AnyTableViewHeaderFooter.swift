//
//  AnyTableViewHeaderFooter.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation
import UIKit

extension TableView {
    public struct AnyHeaderFooter: TableViewHeaderFooter {
        public typealias View = UITableViewHeaderFooterView

        fileprivate let box: AnyTableViewHeaderFooterBox

        @usableFromInline
        init<Cell>(_ cell: Cell) where Cell: TableViewHeaderFooter {
            if let instance = cell as? AnyHeaderFooter {
                self = instance
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

        public func bind(to view: View, at section: Int) {
            box.bind(to: view, at: section)
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

    func bind(to view: UITableViewHeaderFooterView, at section: Int)
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
        func bind(to view: UITableViewHeaderFooterView, at section: Int) {
            guard let view = view as? Base.View else {
                assertionFailure("Opaque cell must associate with view type \(String(describing: Base.View.self))")
                return
            }
            _base.bind(to: view, at: section)
        }

        @inlinable
        func willDisplay(view: UITableViewHeaderFooterView, at section: Int) {
            guard let view = view as? Base.View else { return }
            _base.willDisplay(view: view, at: section)
        }

        @inlinable
        func didEndDisplaying(view: UITableViewHeaderFooterView, at section: Int) {
            guard let view = view as? Base.View else { return }
            _base.didEndDisplaying(view: view, at: section)
        }
    }
}
