//
//  TableViewHeaderFooter.swift
//  RxCoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

public protocol TableViewHeaderFooter: CellRegisterable, HeaderFooterPresentable where View: UITableViewHeaderFooterView {
    associatedtype Model

    typealias BindingFunction = (Model?, View, Int) -> Void

    var position: HeaderFooterPosition { get }
    var height: CGFloat { get }
    var title: String? { get }
    var model: Model? { get }

    func bind(model: Model?, to view: View, at section: Int)
}

extension TableViewHeaderFooter {
    @inlinable
    public func eraseToAny() -> TableView.AnyHeaderFooter { .init(self) }
}

extension TableView {
    @frozen
    public struct HeaderFooter<Model, View>: TableViewHeaderFooter where Model: Equatable, View: UITableViewHeaderFooterView {
        public let type: CellType
        public let reuseIdentifier: String
        public let position: HeaderFooterPosition
        internal(set) public var height: CGFloat
        internal(set) public var title: String?
        public let model: Model?
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var willDisplayHandler: SectionInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: SectionInteractiveHandler?

        public init(position: HeaderFooterPosition, type: CellType = .default, reuseIdentifier: String? = nil, model: Model?) {
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.position = position
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public func height(_ height: CGFloat) -> Self {
            var other = self
            other.height = height
            return other
        }

        public func title(_ title: String?) -> Self {
            var other = self
            other.title = title
            return other
        }

        @inlinable
        public func bind(_ bindingFunction: BindingFunction?) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            return other
        }

        @inlinable
        public func willDisplayHandler(_ willDisplayHandler: SectionInteractiveHandler?) -> Self {
            var other = self
            other.willDisplayHandler = willDisplayHandler
            return other
        }

        @inlinable
        public func didEndDisplayingHandler(_ didEndDisplayingHandler: SectionInteractiveHandler?) -> Self {
            var other = self
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func handlers(bindingFunction: BindingFunction? = nil, willDisplayHandler: SectionInteractiveHandler? = nil, didEndDisplayingHandler: SectionInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at section: Int) {
            bindingFunction?(model, view, section)
        }

        @inlinable
        public func willDisplay(view: View, at section: Int) {
            willDisplayHandler?(view, section)
        }

        @inlinable
        public func didEndDisplaying(view: View, at section: Int) {
            didEndDisplayingHandler?(view, section)
        }
    }
}
