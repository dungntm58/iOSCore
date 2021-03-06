//
//  PaginationDTO.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

public protocol PaginationDTO {
    var total: Int { get }
    var pageSize: Int { get }
    var next: Any { get }
    var previous: Any { get }
}

extension PaginationDTO {
    @inlinable
    public var hasNext: Bool {
        if case Optional<Any>.none = next {
            return false
        } else {
            return true
        }
    }

    @inlinable
    public var hasPrevious: Bool {
        if case Optional<Any>.none = previous {
            return false
        } else {
            return true
        }
    }
}
