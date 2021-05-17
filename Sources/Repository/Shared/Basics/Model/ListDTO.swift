//
//  ListDTO.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

@frozen
public struct ListDTO<T> {
    public let pagination: PaginationDTO?
    public let data: [T]

    public init(data: [T] = [], pagination: PaginationDTO? = nil) {
        self.data = data
        self.pagination = pagination
    }
}
