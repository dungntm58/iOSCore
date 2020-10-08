//
//  TableViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

public protocol TableViewCell: CellRegisterable, CellBinding, CellPresentable, Identifiable where View: UITableViewCell, Model: Equatable {
    var height: CGFloat { get }
}

extension TableViewCell {
    public var height: CGFloat { UITableView.automaticDimension }
}

extension TableViewCell {
    @inlinable
    public func eraseToAny() -> TableView.AnyCell { .init(self) }
}

extension TableView {
    @frozen
    public struct Cell<ID, Model, View>: TableViewCell, TableViewCellBlock, CellPresentable, CellInteractable where ID: Hashable, Model: Equatable, View: UITableViewCell {
        public let id: ID
        public let type: CellType
        public let reuseIdentifier: String
        internal(set) public var height: CGFloat
        public let model: Model?
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didSelectHandler: SelectionInteractiveHandler?
        @usableFromInline
        var didDeselectHandler: SelectionInteractiveHandler?

        public init(id: ID, type: CellType, reuseIdentifier: String? = nil, model: Model?) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public func height(_ height: CGFloat) -> Self {
            var other = self
            other.height = height
            return other
        }

        @inlinable
        public func bind(_ bindingFunction: BindingFunction?) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            return other
        }

        @inlinable
        public func willDisplayHandler(_ willDisplayHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.willDisplayHandler = willDisplayHandler
            return other
        }

        @inlinable
        public func didEndDisplayingHandler(_ didEndDisplayingHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func didSelectHandler(_ didSelectHandler: SelectionInteractiveHandler?) -> Self {
            var other = self
            other.didSelectHandler = didSelectHandler
            return other
        }

        @inlinable
        public func didDeselectHandler(_ willDisplayHandler: SelectionInteractiveHandler?) -> Self {
            var other = self
            other.didDeselectHandler = didDeselectHandler
            return other
        }

        @inlinable
        public func handlers(bindingFunction: BindingFunction? = nil, willDisplayHandler: IndexPathInteractiveHandler? = nil, didEndDisplayingHandler: IndexPathInteractiveHandler? = nil, didSelectHandler: SelectionInteractiveHandler? = nil, didDeselectHandler: SelectionInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            other.didSelectHandler = didSelectHandler
            other.didDeselectHandler = didDeselectHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            bindingFunction?(model, view, indexPath)
        }

        @inlinable
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }

        @inlinable
        public func didSelect(at indexPath: IndexPath) {
            didSelectHandler?(indexPath)
        }

        @inlinable
        public func didDeselect(at indexPath: IndexPath) {
            didDeselectHandler?(indexPath)
        }
    }

    @frozen
    public struct LoadingCell: TableViewCell, TableViewCellBlock, CellPresentable {
        public typealias Model = AnyEquatable
        public typealias View = LoadingTableViewCell

        public let id: LoadingIdentifier
        public let type: CellType
        public let reuseIdentifier: String
        public let height: CGFloat
        public let model: Model?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?

        public init() {
            self.id = .init()
            self.type = .nib(nibName: "LoadingTableViewCell", bundle: Bundle(for: LoadingTableViewCell.classForCoder()))
            self.reuseIdentifier = type.identifier
            self.height = UITableView.automaticDimension
            self.model = nil
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {}

        @inlinable
        public func willDisplayHandler(_ willDisplayHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.willDisplayHandler = willDisplayHandler
            return other
        }

        @inlinable
        public func didEndDisplayingHandler(_ didEndDisplayingHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }
    }

    @frozen
    public struct NestedListCell<ID, Model, View>: TableViewCell, TableViewCellBlock where ID: Hashable, Model: NestedChildListModel & Equatable, View: NestedListViewCell & UITableViewCell {
        public let id: ID
        public let type: CellType
        public let reuseIdentifier: String
        internal(set) public var height: CGFloat
        public let model: Model?
        @usableFromInline
        var bindingFunction: BindingFunction?
        @usableFromInline
        var willDisplayHandler: IndexPathInteractiveHandler?
        @usableFromInline
        var didEndDisplayingHandler: IndexPathInteractiveHandler?

        public init(id: ID, type: CellType, reuseIdentifier: String? = nil, model: Model?) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public func height(_ height: CGFloat) -> Self {
            var other = self
            other.height = height
            return other
        }

        @inlinable
        public func bind(_ bindingFunction: BindingFunction?) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            return other
        }

        @inlinable
        public func willDisplayHandler(_ willDisplayHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.willDisplayHandler = willDisplayHandler
            return other
        }

        @inlinable
        public func didEndDisplayingHandler(_ didEndDisplayingHandler: IndexPathInteractiveHandler?) -> Self {
            var other = self
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func handlers(bindingFunction: BindingFunction? = nil, willDisplayHandler: IndexPathInteractiveHandler? = nil, didEndDisplayingHandler: IndexPathInteractiveHandler? = nil) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            return other
        }

        @inlinable
        public func bind(model: Model?, to view: View, at indexPath: IndexPath) {
            bindingFunction?(model, view, indexPath)
        }

        @inlinable
        public func willDisplay(view: View, at indexPath: IndexPath) {
            willDisplayHandler?(view, indexPath)
        }

        @inlinable
        public func didEndDisplaying(view: View, at indexPath: IndexPath) {
            didEndDisplayingHandler?(view, indexPath)
        }
    }
}

extension TableView.Cell where ID == UniqueIdentifier {
    @inlinable
    public init(type: CellType, reuseIdentifier: String? = nil, model: Model?) {
        self.init(id: .init(), type: type, reuseIdentifier: reuseIdentifier, model: model)
    }
}

public protocol TableViewCellBlock {
    var cells: [TableView.AnyCell] { get }
}

extension TableViewCellBlock where Self: TableViewCell {
    @inlinable
    public var cells: [TableView.AnyCell] { [eraseToAny()] }
}

extension Optional: TableViewCellBlock where Wrapped: TableViewCell {
    @inlinable
    public var cells: [TableView.AnyCell] {
        switch self {
        case .none:
            return []
        case .some(let section):
            return [section.eraseToAny()]
        }
    }
}

extension Array: TableViewCellBlock where Element: TableViewCellBlock {
    @inlinable
    public var cells: [TableView.AnyCell] { flatMap { $0.cells } }
}

extension ForEach: TableViewCellBlock where Content == TableViewCellBlock {
    @inlinable
    public var cells: [TableView.AnyCell] { elements.flatMap { $0.cells } }

    @inlinable
    public init(_ data: Data, @TableView.CellBlockBuilder content: (Int, Data.Element) -> TableViewCellBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
