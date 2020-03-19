//
//  ListCellModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 12/17/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

public enum CellModelType {
    case `default`
    case nib(nibName: String, bundle: Bundle?)
    case `class`(`class`: AnyClass)

    public func makeCell(reuseIdentifier: String? = nil, height: CGFloat = UITableView.automaticDimension, tag: Int = 0) -> CellModel {
        InternalCellModel(
            type: self,
            reuseIdentifier: reuseIdentifier,
            height: height,
            tag: tag
        )
    }

    public func makeHeaderFooter(reuseIdentifier: String? = nil, position: HeaderFooterPosition, height: CGFloat = UITableView.automaticDimension, customView: UIView? = nil, tag: Int = 0) -> HeaderFooterModel {
        InternalHeaderFooterModel(
            type: self,
            reuseIdentifier: reuseIdentifier,
            position: position,
            height: height,
            customView: customView,
            tag: tag
        )
    }
}

public enum HeaderFooterPosition {
    case header
    case footer
}

public protocol CellModel {
    var type: CellModelType { get }
    var reuseIdentifier: String { get }
    var height: CGFloat { set get }
}

public protocol HeaderFooterModel: CellModel {
    var customView: UIView? { set get }
    var title: String? { set get }
    var position: HeaderFooterPosition { get }
}

extension Collection where Element == CellModel {
    public func makeSection(header: HeaderFooterModel? = nil, footer: HeaderFooterModel? = nil) -> SectionModel {
        InternalSectionModel(
            cells: (self as? [CellModel]) ?? Array(self),
            header: header,
            footer: footer
        )
    }

    public func makeSectionWithHeaderFooterType(header: CellModelType? = nil, footer: CellModelType? = nil) -> SectionModel {
        InternalSectionModel(
            cells: (self as? [CellModel]) ?? Array(self),
            header: header?.makeHeaderFooter(position: .header),
            footer: footer?.makeHeaderFooter(position: .footer)
        )
    }
}

extension Collection where Element: CellModel {
    public func makeSection(header: HeaderFooterModel? = nil, footer: HeaderFooterModel? = nil) -> SectionModel {
        InternalSectionModel(
            cells: (self as? [CellModel]) ?? Array(self),
            header: header,
            footer: footer
        )
    }

    public func makeSectionWithHeaderFooterType(header: CellModelType? = nil, footer: CellModelType? = nil) -> SectionModel {
        InternalSectionModel(
            cells: (self as? [CellModel]) ?? Array(self),
            header: header?.makeHeaderFooter(position: .header),
            footer: footer?.makeHeaderFooter(position: .footer)
        )
    }
}
