//
//  DifferenceKit+CollectionView.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/6/20.
//

import DifferenceKit

extension CollectionView.AnyCell: Differentiable {
    @inlinable
    public var differenceIdentifier: ID { id }

    @inlinable
    public func isContentEqual(to source: CollectionView.AnyCell) -> Bool {
        model == source.model
            && reuseIdentifier == source.reuseIdentifier
            && type == source.type
            && estimatedSize == source.estimatedSize
    }
}

extension CollectionView.AnySection: Differentiable, DifferentiableSection {
    public init<C>(source: CollectionView.AnySection, elements: C) where C: Swift.Collection, C.Element == Self.Collection.Element {
        switch elements {
        case let cells as [CollectionView.AnyCell]:
            self.init(source, cells: cells)
        default:
            self.init(source, cells: Array(elements))
        }
    }

    @inlinable
    public var differenceIdentifier: ID { id }

    @inlinable
    public var elements: [CollectionView.AnyCell] { cells }

    @inlinable
    public func isContentEqual(to source: CollectionView.AnySection) -> Bool {
        header == source.header
            && footer == source.footer
    }
}
