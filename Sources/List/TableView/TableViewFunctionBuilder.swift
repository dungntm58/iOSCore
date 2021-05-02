//
//  FunctionBuilder.swift
//  CoreList
//
//  Created by Dung Nguyen on 4/7/20.
//

import Foundation

extension TableView {
    @resultBuilder
    public struct CellBlockBuilder {
        @inlinable
        public static func buildBlock(_ component: TableViewCellBlock...) -> TableViewCellBlock {
            component.flatMap { $0.cells }
        }

        @inlinable
        public static func buildExpression<Cell>(_ expression: Cell?) -> TableViewCellBlock where Cell: TableViewCell {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildExpression(_ expression: TableViewCellBlock?) -> TableViewCellBlock {
            if let component = expression {
                return component
            }
            return [TableView.AnyCell]()
        }

        @inlinable
        public static func buildArray(_ component: [TableViewCellBlock]) -> TableViewCellBlock {
            component.flatMap { $0.cells }
        }

        @inlinable
        public static func buildIf(_ component: TableViewCellBlock?) -> TableViewCellBlock {
            if let component = component {
                return component
            }
            return [TableView.AnyCell]()
        }

        @inlinable
        public static func buildEither(first: TableViewCellBlock) -> TableViewCellBlock {
            first
        }

        @inlinable
        public static func buildEither(second: TableViewCellBlock) -> TableViewCellBlock {
            second
        }

        @inlinable
        public static func buildOptional(_ component: TableViewCellBlock?) -> TableViewCellBlock {
            if let component = component {
                return component
            }
            return [TableView.AnyCell]()
        }
    }

    @resultBuilder
    public struct SectionBlockBuilder {
        @inlinable
        public static func buildBlock(_ component: TableViewSectionBlock...) -> TableViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildExpression<Section>(_ expression: Section?) -> TableViewSectionBlock where Section: TableViewSection {
            expression.map { [$0] } ?? []
        }

        @inlinable
        public static func buildExpression(_ expression: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = expression {
                return component
            }
            return [TableView.AnySection]()
        }

        @inlinable
        public static func buildArray(_ component: [TableViewSectionBlock]) -> TableViewSectionBlock {
            component.flatMap { $0.sections }
        }

        @inlinable
        public static func buildIf(_ component: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = component {
                return component
            }
            return [TableView.AnySection]()
        }

        @inlinable
        public static func buildEither(first: TableViewSectionBlock) -> TableViewSectionBlock {
            first
        }

        @inlinable
        public static func buildEither(second: TableViewSectionBlock) -> TableViewSectionBlock {
            second
        }

        @inlinable
        public static func buildOptional(_ component: TableViewSectionBlock?) -> TableViewSectionBlock {
            if let component = component {
                return component
            }
            return [TableView.AnySection]()
        }
    }

    @resultBuilder
    public struct SectionBuilder<Header, Footer> where Header: TableViewHeaderFooter, Footer: TableViewHeaderFooter {
        @usableFromInline
        let header: Header?
        @usableFromInline
        let footer: Footer?
        @usableFromInline
        let cells: [AnyCell]

        @usableFromInline
        init(header: Header?, cells: [AnyCell] = [], footer: Footer?) {
            precondition(header == nil || header?.position == .header)
            precondition(footer == nil || footer?.position == .footer)

            self.header = header
            self.cells = cells
            self.footer = footer
        }

        @usableFromInline
        init(header: Header?, cellBlock: TableViewCellBlock..., footer: Footer?) {
            self.init(header: header, cells: cellBlock.flatMap { $0.cells }, footer: footer)
        }

        @usableFromInline
        init(header: Header?, cellBlocks: [TableViewCellBlock], footer: Footer?) {
            self.init(header: header, cells: cellBlocks.flatMap { $0.cells }, footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock: TableViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
            .init(header: header, cells: cellBlock.cells, footer: footer)
        }

        @inlinable
        public static func buildBlock(
            _ header: Header? = nil,
            _ cellBlock1: TableViewCellBlock,
            _ cellBlock2: TableViewCellBlock,
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
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
            _ footer: Footer? = nil
        ) -> Self {
            let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
            let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
            let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
            return .init(header: header,
                         cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                         footer: footer)
        }
    }
}

extension TableView.SectionBuilder where Header == TableView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(
        _ cellBlock: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil, cells: cellBlock.cells, footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock,
        _ cellBlock8: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: footer)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock,
        _ cellBlock8: TableViewCellBlock,
        _ cellBlock9: TableViewCellBlock,
        _ footer: Footer? = nil
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: footer)
    }
}

extension TableView.SectionBuilder where Footer == TableView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock: TableViewCellBlock
    ) -> Self {
        .init(header: header, cells: cellBlock.cells, footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock
    ) -> Self {
        .init(header: header,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock
    ) -> Self {
        .init(header: header,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ header: Header? = nil,
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: nil)
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
        _ cellBlock7: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: nil)
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
        _ cellBlock8: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
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
        _ cellBlock9: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: header,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }
}

extension TableView.SectionBuilder where Header == TableView.AnyHeaderFooter, Footer == TableView.AnyHeaderFooter {
    @inlinable
    public static func buildBlock(_ cellBlock: TableViewCellBlock) -> Self {
        .init(header: nil, cells: cellBlock.cells, footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock
    ) -> Self {
        .init(header: nil,
              cells: cellBlock1.cells + cellBlock2.cells + cellBlock3.cells,
              footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlock4.cells + cellBlock5.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlock7.cells,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock,
        _ cellBlock8: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }

    @inlinable
    public static func buildBlock(
        _ cellBlock1: TableViewCellBlock,
        _ cellBlock2: TableViewCellBlock,
        _ cellBlock3: TableViewCellBlock,
        _ cellBlock4: TableViewCellBlock,
        _ cellBlock5: TableViewCellBlock,
        _ cellBlock6: TableViewCellBlock,
        _ cellBlock7: TableViewCellBlock,
        _ cellBlock8: TableViewCellBlock,
        _ cellBlock9: TableViewCellBlock
    ) -> Self {
        let cellBlocks0 = cellBlock1.cells + cellBlock2.cells + cellBlock3.cells
        let cellBlocks1 = cellBlock4.cells + cellBlock5.cells + cellBlock6.cells
        let cellBlocks2 = cellBlock7.cells + cellBlock8.cells + cellBlock9.cells
        return .init(header: nil,
                     cells: cellBlocks0 + cellBlocks1 + cellBlocks2,
                     footer: nil)
    }
}
