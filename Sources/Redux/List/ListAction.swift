//
//  ListAction.swift
//  RxCoreRedux
//
//  Created by Robert Nguyen on 6/8/19.
//

public protocol ListActionType: ErrorActionType {
    static var updateListState: Self { get }
    static var load: Self { get }
} 
