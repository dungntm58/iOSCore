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
    public struct Cell<ID, Model, View>: TableViewCell, TableViewCellBlock, CellInteractable where ID: Hashable, Model: Equatable, View: UITableViewCell {
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

        public init(id: ID, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public init(id: ID, cellType: View.Type, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public init(id: ID, cellType: View.Type, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            let type: CellType
            if cellType === UITableViewCell.self {
                type = .default
            } else {
                type = .nib(nibName: String(describing: cellType), bundle: Bundle(for: View.classForCoder()))
            }
            self.type = type
            self.reuseIdentifier = reuseIdentifier ?? type.identifier
            self.height = UITableView.automaticDimension
            self.model = model
        }

        public init(id: ID, reuseIdentifier: String? = nil, model: Model? = nil) {
            self.id = id
            let type: CellType
            if View.self === UITableViewCell.self {
                type = .default
            } else {
                type = .nib(nibName: String(describing: View.self), bundle: Bundle(for: View.classForCoder()))
            }
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
}

extension TableView.Cell where ID == UniqueIdentifier {
    @inlinable
    public init(type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), type: type, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(cellType: View.Type, type: CellType, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(cellType: View.Type, reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), cellType: cellType, reuseIdentifier: reuseIdentifier, model: model)
    }

    @inlinable
    public init(reuseIdentifier: String? = nil, model: Model? = nil) {
        self.init(id: .init(), reuseIdentifier: reuseIdentifier, model: model)
    }
}

extension TableView.Cell where Model == AnyEquatable {
    @inlinable
    public init(id: ID, type: CellType, reuseIdentifier: String? = nil) {
        self.init(id: id, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, cellType: View.Type, reuseIdentifier: String? = nil) {
        self.init(id: id, cellType: cellType, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, cellType: View.Type, type: CellType, reuseIdentifier: String? = nil) {
        self.init(id: id, cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(id: ID, reuseIdentifier: String? = nil) {
        self.init(id: id, reuseIdentifier: reuseIdentifier, model: nil)
    }
}

extension TableView.Cell where ID == UniqueIdentifier, Model == AnyEquatable {
    @inlinable
    public init(type: CellType, reuseIdentifier: String? = nil) {
        self.init(type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(cellType: View.Type, reuseIdentifier: String? = nil) {
        self.init(cellType: cellType, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(cellType: View.Type, type: CellType, reuseIdentifier: String? = nil) {
        self.init(cellType: cellType, type: type, reuseIdentifier: reuseIdentifier, model: nil)
    }

    @inlinable
    public init(reuseIdentifier: String? = nil) {
        self.init(reuseIdentifier: reuseIdentifier, model: nil)
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

@available(*, deprecated)
extension ForEach: TableViewCellBlock where Content == TableViewCellBlock {
    @inlinable
    public var cells: [TableView.AnyCell] { elements.flatMap { $0.cells } }

    @inlinable
    public init(_ data: Data, @TableView.CellBlockBuilder content: (Int, Data.Element) -> TableViewCellBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
