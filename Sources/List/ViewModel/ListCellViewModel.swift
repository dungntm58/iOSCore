//
//  ListCellViewModel.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 12/18/18.
//  Copyright © 2018 Robert Nguyen. All rights reserved.
//

open class DefaultCellModel: CellModel {
    open var tag: Int
    open var height: CGFloat
    public let reuseIdentifier: String

    public weak var section: SectionModel?
    public let type: CellModelType

    public init(type: CellModelType, reuseIdentifier: String? = nil, height: CGFloat = UITableView.automaticDimension, tag: Int = 0) {
        self.height = height
        self.type = type
        self.tag = tag

        if let reuseIdentifier = reuseIdentifier {
            self.reuseIdentifier = reuseIdentifier
            return
        }

        switch type {
        case .default:
            self.reuseIdentifier = "Cell"
        case .nib(let nibName, _):
            self.reuseIdentifier = nibName
        case .class(let `class`):
            self.reuseIdentifier = String(describing: `class`)
        }
    }
}

open class DefaultHeaderFooterModel: DefaultCellModel, HeaderFooterModel {
    open var title: String?

    public let position: HeaderFooterPosition

    public init(type: CellModelType, reuseIdentifier: String? = nil, position: HeaderFooterPosition, height: CGFloat = UITableView.automaticDimension, tag: Int = 0) {
        self.position = position
        super.init(type: type, reuseIdentifier: reuseIdentifier, height: height, tag: tag)
    }
}
