//
//  CollectionViewSection.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation
import UIKit

@frozen public enum CollectionView {
    public static var sectionInset: UIEdgeInsets = .zero
    public static var sectionMinimumLineSpacing: CGFloat = 0
    public static var sectionMinimumInteritemSpacing: CGFloat = 0
}

public protocol CollectionViewSection {
    associatedtype ID: Hashable

    var id: ID { get }
    var header: CollectionView.AnyHeaderFooter? { get }
    var footer: CollectionView.AnyHeaderFooter? { get }
    var cells: [CollectionView.AnyCell] { get }
    var inset: UIEdgeInsets { get }
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
}

extension CollectionViewSection {
    @inlinable
    public var hasHeader: Bool {
        guard let header = header else {
            return false
        }
        return header.position == .header
    }

    @inlinable
    public var hasFooter: Bool {
        guard let footer = footer else {
            return false
        }
        return footer.position == .footer
    }

    @inlinable
    public func eraseToAny() -> CollectionView.AnySection { .init(self) }

    @inlinable
    public func register(in collectionView: UICollectionView) {
        if hasHeader {
            header.map { collectionView.register(headerFooter: $0) }
        }
        if hasFooter {
            footer.map { collectionView.register(headerFooter: $0) }
        }
        cells.forEach(collectionView.register)
    }
}

extension CollectionView {
    @frozen
    public struct Section<ID>: CollectionViewSection where ID: Hashable {
        public let id: ID
        public internal(set) var header: AnyHeaderFooter?
        public internal(set) var footer: AnyHeaderFooter?
        public internal(set) var cells: [AnyCell]
        public internal(set) var inset: UIEdgeInsets = CollectionView.sectionInset
        public internal(set) var minimumLineSpacing: CGFloat = CollectionView.sectionMinimumLineSpacing
        public internal(set) var minimumInteritemSpacing: CGFloat = CollectionView.sectionMinimumInteritemSpacing

        public init(id: ID) {
            self.id = id
            self.header = nil
            self.footer = nil
            self.cells = []
        }

        public init(id: ID, @SectionBuilder _ sectionBuilder: () -> CollectionViewSectionComponent) {
            self.id = id
            let builder = sectionBuilder()
            (self.header, self.footer) = builder.asHeaderFooter()
            self.cells = builder.asCells()
        }

        public func refine(@SectionBuilder _ sectionBuilder: () -> CollectionViewSectionComponent) -> Self {
            var other = self
            let builder = sectionBuilder()
            let builtHeaderFooter = builder.asHeaderFooter()
            (other.header, other.footer) = (header ?? builtHeaderFooter.0, footer ?? builtHeaderFooter.1)
            other.cells = builder.asCells()
            return other
        }

        public func inset(_ inset: UIEdgeInsets) -> Self {
            var other = self
            other.inset = inset
            return other
        }

        public func inset(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
            var other = self
            other.inset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            return other
        }

        public func minimumLineSpacing(_ minimumLineSpacing: CGFloat) -> Self {
            var other = self
            other.minimumLineSpacing = minimumLineSpacing
            return other
        }

        public func minimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> Self {
            var other = self
            other.minimumInteritemSpacing = minimumInteritemSpacing
            return other
        }
    }
}

extension CollectionView.Section where ID == UniqueIdentifier {
    @inlinable
    public init(@CollectionView.SectionBuilder _ sectionBuilder: () -> CollectionViewSectionComponent) {
        self.init(id: .init(), sectionBuilder)
    }

    @inlinable
    public init() {
        self.init(id: .init())
    }

    init(component: CollectionViewSectionComponent) {
        self.id = .init()
        (self.header, self.footer) = component.asHeaderFooter()
        self.cells = component.asCells()
    }
}

public protocol CollectionViewSectionBlock {
    var sections: [CollectionView.AnySection] { get }
}

extension CollectionViewSectionBlock where Self: CollectionViewSection {
    @inlinable
    public var sections: [CollectionView.AnySection] { [eraseToAny()] }
}

extension Array: CollectionViewSectionBlock where Element: CollectionViewSection {
    @inlinable
    public var sections: [CollectionView.AnySection] { map { $0.eraseToAny() } }
}

@available(*, deprecated)
extension ForEach: CollectionViewSectionBlock where Content == CollectionViewSectionBlock {
    @inlinable
    public var sections: [CollectionView.AnySection] { elements.flatMap { $0.sections } }

    @inlinable
    public init(_ data: Data, @CollectionView.SectionBlockBuilder content: (Int, Data.Element) -> CollectionViewSectionBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
