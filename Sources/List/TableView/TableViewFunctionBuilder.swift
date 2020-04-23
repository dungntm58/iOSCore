//
//  FunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension TableView {
    @_functionBuilder
    public struct CellBlockBuilder {
        @inlinable
        public static func buildBlock(_ cellBlock: TableViewCellBlock...) -> TableViewCellBlock {
            cellBlock.flatMap { $0.cells }
        }
    }

    @_functionBuilder
    public struct SectionBlockBuilder {
        @inlinable
        public static func buildBlock(_ sectionsBlock: TableViewSectionBlock...) -> TableViewSectionBlock {
            sectionsBlock.flatMap { $0.sections }
        }
    }

    @_functionBuilder
    public struct SectionBuilder<Header, Footer> where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
        @usableFromInline
        let header: Header?
        @usableFromInline
        let footer: Footer?
        @usableFromInline
        let cells: [AnyCell]

        @usableFromInline
        init(header: Header?, cells: [AnyCell], footer: Footer?) {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            self.header = header
            self.cells = cells
            self.footer = footer
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            .init(header: header, cells: cellBlock.cells, footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            .init(header: header,
                  cells: cellBlock1.cells + cellBlock2.cells,
                  footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            .init(header: header,
                  cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
                  footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlock4.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ cellBlock5: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ cellBlock5: TableViewCellBlock,
            _ cellBlock6: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ cellBlock5: TableViewCellBlock,
            _ cellBlock6: TableViewCellBlock,
            _ cellBlock7: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ cellBlock5: TableViewCellBlock,
            _ cellBlock6: TableViewCellBlock,
            _ cellBlock7: TableViewCellBlock,
            _ cellBlock8: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                         footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ cellBlock3: TableViewCellBlock,
            _ cellBlock4: TableViewCellBlock,
            _ cellBlock5: TableViewCellBlock,
            _ cellBlock6: TableViewCellBlock,
            _ cellBlock7: TableViewCellBlock,
            _ cellBlock8: TableViewCellBlock,
            _ cellBlock9: TableViewCellBlock,
            _ footer: Footer? = nil) -> SectionBuilder {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                         footer: footer)
        }
    }
}
