//
//  ListAction.swift
//  CoreRedux
//
//  Created by Robert Nguyen on 6/8/19.
//

import CoreRedux

public protocol ListActionType: ErrorActionType {
    static var updateListState: Self { get }
    static var load: Self { get }
}
