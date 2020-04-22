//
//  CollectionViewSection.swift
//  RxCoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

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
    public var hasHeader: Bool {
        guard let header = header else {
            return false
        }
        return header.position == .header
    }

    public var hasFooter: Bool {
        guard let footer = footer else {
            return false
        }
        return footer.position == .footer
    }

    @inlinable
    public func eraseToAny() -> CollectionView.AnySection { .init(self) }

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
    public struct Section<ID>: CollectionViewSection, CollectionViewSectionBlock where ID: Hashable {
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

        public init(id: ID, @CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) {
            self.id = id
            self.header = nil
            self.footer = nil
            self.cells = CellBlockBuilder().cells
        }

        public func refine<Header, Footer>(header: Header?, footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) -> Self where Header: CollectionViewHeaderFooter, Footer: CollectionViewHeaderFooter {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            var other = self
            other.header = header?.eraseToAny()
            other.footer = footer?.eraseToAny()
            other.cells = CellBlockBuilder().cells
            return other
        }

        public func refine<Header>(header: Header?, @CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) -> Self where Header: CollectionViewHeaderFooter {
            return refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine<Footer>(footer: Footer?, @CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) -> Self where Footer: CollectionViewHeaderFooter {
            return refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine(@CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) -> Self {
            return refine(header: header, footer: footer, CellBlockBuilder)
        }

        public func refine<Header, Footer>(@SectionBuilder<Header, Footer> _ SectionBuilder: () -> SectionBuilder<Header, Footer>) -> Self where Header: CollectionViewHeaderFooter, Footer: CollectionViewHeaderFooter {
            var other = self
            let builder = SectionBuilder()
            other.header = builder.header?.eraseToAny()
            other.footer = builder.footer?.eraseToAny()
            other.cells = builder.cells
            return other
        }

        public func inset(_ inset: UIEdgeInsets) -> Self {
            var other = self
            other.inset = inset
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
    public init(@CollectionView.CellBlockBuilder _ CellBlockBuilder: () -> CollectionViewCellBlock) {
        self.init(id: .init(), CellBlockBuilder)
    }

    public init() {
        self.init(id: .init())
    }
}

public protocol CollectionViewSectionBlock {
    var sections: [CollectionView.AnySection] { get }
}

extension CollectionViewSectionBlock where Self: CollectionViewSection {
    public var sections: [CollectionView.AnySection] { [eraseToAny()] }
}

extension Optional: CollectionViewSectionBlock where Wrapped: CollectionViewSection {
    public var sections: [CollectionView.AnySection] {
        switch self {
        case .none:
            return []
        case .some(let section):
            return [section.eraseToAny()]
        }
    }
}

extension Array: CollectionViewSectionBlock where Element: CollectionViewSectionBlock {
    public var sections: [CollectionView.AnySection] { flatMap { $0.sections } }
}

extension ForEach: CollectionViewSectionBlock where Content == CollectionViewSectionBlock {
    public var sections: [CollectionView.AnySection] { elements.flatMap { $0.sections } }

    @inlinable
    public init(_ data: Data, @CollectionView.SectionBlockBuilder content: (Int, Data.Element) -> CollectionViewSectionBlock) {
        self.init(data, elements: data.enumerated().map(content))
    }
}
