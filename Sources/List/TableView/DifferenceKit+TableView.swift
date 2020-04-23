//
//  DifferenceKit+TableView.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import DifferenceKit

extension TableView.Cell: Differentiable {
    public var differenceIdentifier: ID { id }

    public func isContentEqual(to source: TableView.Cell<ID, Model, View>) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && height == source.height
    }
}

extension TableView.AnyCell: Differentiable {
    public var differenceIdentifier: ID { id }

    public func isContentEqual(to source: TableView.AnyCell) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && height == source.height
    }
}

extension TableView.Section: Differentiable, DifferentiableSection {
    public init<C>(source: TableView.Section<ID>, elements: C) where C : Swift.Collection, C.Element == Self.Collection.Element {
        self.id = source.id
        self.header = source.header
        self.footer = source.footer
        switch elements {
        case let cells as Array<TableView.AnyCell>:
            self.cells = cells
        default:
            self.cells = Array(elements)
        }
    }

    public var differenceIdentifier: ID { id }

    public var elements: [TableView.AnyCell] { cells }

    public func isContentEqual(to source: TableView.Section<ID>) -> Bool {
        header.eraseToAny() == source.header.eraseToAny()
            && footer.eraseToAny() == source.footer.eraseToAny()
    }
}

extension TableView.AnySection: Differentiable, DifferentiableSection {
    public init<C>(source: TableView.AnySection, elements: C) where C : Swift.Collection, C.Element == Self.Collection.Element {
        switch elements {
        case let cells as Array<TableView.AnyCell>:
            self.init(source, cells: cells)
        default:
            self.init(source, cells: Array(elements))
        }
    }

    public var differenceIdentifier: ID { id }

    public var elements: [TableView.AnyCell] { cells }

    public func isContentEqual(to source: TableView.AnySection) -> Bool {
        header == source.header
            && footer == source.footer
    }
}
