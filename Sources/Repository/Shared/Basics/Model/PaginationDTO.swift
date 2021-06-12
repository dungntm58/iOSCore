//
//  PaginationDTO.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

public protocol Paginated {
    var total: Int { get }
    var page: Int { get }
    var totalPage: Int { get }
    var pageSize: Int { get }
    var hasNext: Bool { get }
    var hasPrevious: Bool { get }
}

extension Paginated {
    @inlinable
    public var hasNext: Bool { page < totalPage }
}
