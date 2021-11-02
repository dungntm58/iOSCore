//
//  TableViewCell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import UIKit
import FoundationExtInternal

public protocol TableViewSectionComponent {
    func asCells() -> [TableView.AnyCell]
    func asHeaderFooter() -> (TableView.AnyHeaderFooter?, TableView.AnyHeaderFooter?)
}

public protocol TableViewCell: TableViewSectionComponent, CellRegisterable, CellBinding, CellPresentable, Identifiable where View: UITableViewCell, Model: Equatable {
    var height: CGFloat { get }
}

extension TableViewCell {
    @inlinable
    public var height: CGFloat { UITableView.automaticDimension }

    @inlinable
    public func asCells() -> [TableView.AnyCell] { [eraseToAny()] }

    @inlinable
    public func asHeaderFooter() -> (TableView.AnyHeaderFooter?, TableView.AnyHeaderFooter?) {
        (nil, nil)
    }

    @inlinable
    public func eraseToAny() -> TableView.AnyCell { .init(self) }
}

extension TableView {
    @frozen
    public struct Cell<ID, Model, View>: TableViewCell, CellInteractable where ID: Hashable, Model: Equatable, View: UITableViewCell {
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
#if SWIFT_PACKAGE && swift(>=5.3)
                type = .class(class: cellType)
#else
                type = .nib(nibName: String(describing: cellType), bundle: Bundle(for: View.classForCoder()))
#endif
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
#if SWIFT_PACKAGE && swift(>=5.3)
                type = .class(class: View.self)
#else
                type = .nib(nibName: String(describing: View.self), bundle: Bundle(for: View.classForCoder()))
#endif
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
        public func handlers(
            bindingFunction: BindingFunction? = nil,
            willDisplayHandler: IndexPathInteractiveHandler? = nil,
            didEndDisplayingHandler: IndexPathInteractiveHandler? = nil,
            didSelectHandler: SelectionInteractiveHandler? = nil,
            didDeselectHandler: SelectionInteractiveHandler? = nil
        ) -> Self {
            var other = self
            other.bindingFunction = bindingFunction
            other.willDisplayHandler = willDisplayHandler
            other.didEndDisplayingHandler = didEndDisplayingHandler
            other.didSelectHandler = didSelectHandler
            other.didDeselectHandler = didDeselectHandler
            return other
        }

        @inlinable
        public func bind(to view: View, at indexPath: IndexPath) {
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
    public struct LoadingCell: TableViewCell, CellPresentable {
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
#if SWIFT_PACKAGE && swift(>=5.3)
            self.type = .nib(nibName: "LoadingTableViewCell", bundle: .module)
#else
            self.type = .nib(nibName: "LoadingTableViewCell", bundle: Bundle(for: LoadingTableViewCell.classForCoder()))
#endif
            self.reuseIdentifier = type.identifier
            self.height = UITableView.automaticDimension
            self.model = nil
        }

        @inlinable
        public func bind(to view: View, at indexPath: IndexPath) {}

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

extension Array: TableViewSectionComponent where Element: TableViewCell {
    @inlinable
    public func asCells() -> [TableView.AnyCell] { map { $0.eraseToAny() } }

    @inlinable
    public func asHeaderFooter() -> (TableView.AnyHeaderFooter?, TableView.AnyHeaderFooter?) { (nil, nil) }
}

@available(*, deprecated)
extension ForEach: TableViewSectionComponent where Content == TableViewSectionComponent {
    @inlinable
    public func asCells() -> [TableView.AnyCell] { elements.flatMap { $0.asCells() } }

    @inlinable
    public func asHeaderFooter() -> (TableView.AnyHeaderFooter?, TableView.AnyHeaderFooter?) {
        (nil, nil)
    }

    @inlinable
    public init(_ data: Data, @TableView.SectionBuilder content: (Int, Data.Element) -> TableViewSectionComponent) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
