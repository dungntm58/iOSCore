//
//  BaseListView.swift
//  RxCoreList
//
//  Created by Robert Nguyen on 11/19/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

public enum ListModelChangeType {
    public enum ChangedPosition {
        case begin(length: Int)
        case middle(at: Int, length: Int)
        case end(length: Int)
    }

    case initial
    case addNew(at: ChangedPosition)
    case remove(at: ChangedPosition)
    case swap(from: Int, to: Int)
    case replace(at: Int, length: Int)
}

