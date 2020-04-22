//
//  AnyTableViewSection.swift
//  RxCoreList
//
//  Created by Robert on 4/5/20.
//

import Foundation

extension TableView {
    public struct AnySection: TableViewSection, TableViewSectionBlock {
        private var box: AnyTableViewSectionBox

        @usableFromInline
        init<Section>(_ section: Section) where Section: TableViewSection {
            if let _section = section as? AnySection {
                self = _section
            } else {
                self.box = SectionBox(section)
            }
        }

        @usableFromInline
        init<Section>(_ section: Section, cells: [AnyCell]) where Section: TableViewSection {
            if let _section = section as? AnySection {
                self = _section
                self.box.cells = cells
            } else {
                self.box = SectionBox(section, cells: cells)
            }
        }

        public var id: AnyHashable { box.id }
        public var header: AnyHeaderFooter? { box.header }
        public var footer: AnyHeaderFooter? { box.footer }
        public var cells: [AnyCell] { box.cells }
    }
}

private protocol AnyTableViewSectionBox {
    var id: AnyHashable { get }
    var header: TableView.AnyHeaderFooter? { get }
    var footer: TableView.AnyHeaderFooter? { get }
    var cells: [TableView.AnyCell] { set get }
}

private extension TableView {
    struct SectionBox<Base>: AnyTableViewSectionBox where Base: TableViewSection {
        @usableFromInline
        let id: AnyHashable
        @usableFromInline
        let header: AnyHeaderFooter?
        @usableFromInline
        let footer: AnyHeaderFooter?
        @usableFromInline
        var cells: [AnyCell]

        @usableFromInline
        init(_ base: Base) {
            self.id = base.id
            self.header = base.header
            self.footer = base.footer
            self.cells = base.cells
        }

        @usableFromInline
        init(_ base: Base, cells: [AnyCell]) {
            self.id = base.id
            self.header = base.header
            self.footer = base.footer
            self.cells = cells
        }
    }
}
