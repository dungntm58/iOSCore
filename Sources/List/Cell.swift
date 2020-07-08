//
//  Cell.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

@frozen
public enum CellType {
    case `default`
    case nib(nibName: String, bundle: Bundle?)
    case `class`(`class`: AnyClass)

    @inlinable
    public var identifier: String {
        switch self {
        case .default:
            return "Cell"
        case .nib(let nibName, _):
            return nibName
        case .class(let `class`):
            return String(describing: `class`)
        }
    }
}

public protocol CellRegisterable {
    var type: CellType { get }
    var reuseIdentifier: String { get }
}

extension CellRegisterable {
    @inlinable
    public var reuseIdentifier: String { type.identifier }
}

public protocol ViewAssociatable {
    associatedtype View: UIView

    typealias IndexPathInteractiveHandler = (View, IndexPath) -> Void
    typealias SectionInteractiveHandler = (View, Int) -> Void
}

public protocol CellBinding: ViewAssociatable {
    associatedtype Model

    typealias BindingFunction = (Model?, View, IndexPath) -> Void

    var model: Model? { get }
    func bind(model: Model?, to view: View, at indexPath: IndexPath)
}

public protocol CellPresentable: ViewAssociatable {
    func willDisplay(view: View, at indexPath: IndexPath)
    func didEndDisplaying(view: View, at indexPath: IndexPath)
}

public protocol CellInteractable {
    typealias SelectionInteractiveHandler = (IndexPath) -> Void

    func didSelect(at indexPath: IndexPath)
    func didDeselect(at indexPath: IndexPath)
}

public protocol HeaderFooterPresentable: ViewAssociatable {
    func willDisplay(view: View, at section: Int)
    func didEndDisplaying(view: View, at section: Int)
}
