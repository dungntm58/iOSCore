//
//  DifferenceKit+CollectionView.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import DifferenceKit

extension CollectionView.Cell: Differentiable {
    public var differenceIdentifier: ID { id }

    public func isContentEqual(to source: CollectionView.Cell<ID, Model, View>) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && size == source.size
    }
}

extension CollectionView.AnyCell: Differentiable {
    public var differenceIdentifier: ID { id }

    public func isContentEqual(to source: CollectionView.AnyCell) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && size == source.size
    }
}

extension CollectionView.Section: Differentiable, DifferentiableSection {
    public init<C>(source: CollectionView.Section<ID>, elements: C) where C : Swift.Collection, C.Element == Self.Collection.Element {
        self.id = source.id
        self.header = source.header
        self.footer = source.footer
        switch elements {
        case let cells as Array<CollectionView.AnyCell>:
            self.cells = cells
        default:
            self.cells = Array(elements)
        }
    }

    public var differenceIdentifier: ID { id }

    public var elements: [CollectionView.AnyCell] { cells }

    public func isContentEqual(to source: CollectionView.Section<ID>) -> Bool {
        header.eraseToAny() == source.header.eraseToAny()
            && footer.eraseToAny() == source.footer.eraseToAny()
    }
}

extension CollectionView.AnySection: Differentiable, DifferentiableSection {
    public init<C>(source: CollectionView.AnySection, elements: C) where C : Swift.Collection, C.Element == Self.Collection.Element {
        switch elements {
        case let cells as Array<CollectionView.AnyCell>:
            self.init(source, cells: cells)
        default:
            self.init(source, cells: Array(elements))
        }
    }

    public var differenceIdentifier: ID { id }

    public var elements: [CollectionView.AnyCell] { cells }

    public func isContentEqual(to source: CollectionView.AnySection) -> Bool {
        header == source.header
            && footer == source.footer
    }
}
