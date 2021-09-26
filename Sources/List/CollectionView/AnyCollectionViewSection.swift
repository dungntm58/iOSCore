//
//  AnyCollectionViewSection.swift
//  CoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation
import UIKit

extension CollectionView {
    public struct AnySection: CollectionViewSection {
        private var box: AnyCollectionViewSectionBox

        @usableFromInline
        init<Section>(_ section: Section) where Section: CollectionViewSection {
            if let instance = section as? AnySection {
                self = instance
            } else {
                self.box = SectionBox(section)
            }
        }

        @usableFromInline
        init<Section>(_ section: Section, cells: [AnyCell]) where Section: CollectionViewSection {
            if let instance = section as? AnySection {
                self = instance
                self.box.cells = cells
            } else {
                self.box = SectionBox(section, cells: cells)
            }
        }

        public var id: AnyHashable { box.id }
        public var header: AnyHeaderFooter? { box.header }
        public var footer: AnyHeaderFooter? { box.footer }
        public var cells: [AnyCell] { box.cells }
        public var inset: UIEdgeInsets { box.inset }
        public var minimumLineSpacing: CGFloat { box.minimumLineSpacing }
        public var minimumInteritemSpacing: CGFloat { box.minimumInteritemSpacing }
    }
}

private protocol AnyCollectionViewSectionBox {
    var id: AnyHashable { get }
    var header: CollectionView.AnyHeaderFooter? { get }
    var footer: CollectionView.AnyHeaderFooter? { get }
    var cells: [CollectionView.AnyCell] { get set }
    var inset: UIEdgeInsets { get }
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }
}

private extension CollectionView {
    struct SectionBox<Base>: AnyCollectionViewSectionBox where Base: CollectionViewSection {
        @usableFromInline
        let id: AnyHashable
        @usableFromInline
        let header: AnyHeaderFooter?
        @usableFromInline
        let footer: AnyHeaderFooter?
        @usableFromInline
        var cells: [AnyCell]
        @usableFromInline
        let inset: UIEdgeInsets
        @usableFromInline
        let minimumLineSpacing: CGFloat
        @usableFromInline
        let minimumInteritemSpacing: CGFloat

        @usableFromInline
        init(_ base: Base) {
            self.id = base.id
            self.header = base.header
            self.footer = base.footer
            self.cells = base.cells
            self.inset = base.inset
            self.minimumLineSpacing = base.minimumLineSpacing
            self.minimumInteritemSpacing = base.minimumInteritemSpacing
        }

        @usableFromInline
        init(_ base: Base, cells: [AnyCell]) {
            self.id = base.id
            self.header = base.header
            self.footer = base.footer
            self.cells = cells
            self.inset = base.inset
            self.minimumLineSpacing = base.minimumLineSpacing
            self.minimumInteritemSpacing = base.minimumInteritemSpacing
        }
    }
}
