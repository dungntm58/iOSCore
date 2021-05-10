//
//  DifferenceKit+TableView.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import DifferenceKit

extension TableView.AnyCell: Differentiable {
    @inlinable
    public var differenceIdentifier: ID { id }

    @inlinable
    public func isContentEqual(to source: TableView.AnyCell) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && type == source.type
            && height == source.height
    }
}

extension TableView.AnySection: Differentiable, DifferentiableSection {
    public init<C>(source: TableView.AnySection, elements: C) where C: Swift.Collection, C.Element == Self.Collection.Element {
        switch elements {
        case let cells as [TableView.AnyCell]:
            self.init(source, cells: cells)
        default:
            self.init(source, cells: Array(elements))
        }
    }

    @inlinable
    public var differenceIdentifier: ID { id }

    @inlinable
    public var elements: [TableView.AnyCell] { cells }

    @inlinable
    public func isContentEqual(to source: TableView.AnySection) -> Bool {
        header == source.header
            && footer == source.footer
    }
}
