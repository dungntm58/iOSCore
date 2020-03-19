//
//  ListSectionModel.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 12/18/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

public protocol SectionModel: class {
    var tag: Int { set get }
    var cells: [CellModel] { set get }

    var header: HeaderFooterModel? { set get }
    var footer: HeaderFooterModel? { set get }

    var hasHeader: Bool { get }
    var hasFooter: Bool { get }
}

public extension SectionModel {
    var hasHeader: Bool { header != nil }
    var hasFooter: Bool { footer != nil }
}
