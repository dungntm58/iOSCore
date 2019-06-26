//
//  ListSectionModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/18/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

public protocol SectionModel: class {
    var tag: Int { set get }
    var cells: [CellModel] { get }

    var header: HeaderFooterModel? { get }
    var footer: HeaderFooterModel? { get }

    var hasHeader: Bool { get }
    var hasFooter: Bool { get }
}

public extension SectionModel {
    var hasHeader: Bool {
        return header != nil
    }

    var hasFooter: Bool {
        return footer != nil
    }
}
