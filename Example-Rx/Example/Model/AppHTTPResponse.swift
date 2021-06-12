//
//  HTTPResponse.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreRepository

struct AppPaginationDTO: Paginated, Decodable {
    let total: Int
    let pageSize: Int
    let next: Any
    let previous: Any
    let totalPage: Int
    let page: Int
    
    enum CodingKeys: CodingKey {
        case total
        case pageSize
        case next
        case previous
        case page
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Int.self, forKey: .total)
        page = try container.decode(Int.self, forKey: .page)
        totalPage = 0
        pageSize = try container.decode(Int.self, forKey: .pageSize)
        next = (try? container.decode(Int.self, forKey: .next)) as Any
        previous = (try? container.decode(Int.self, forKey: .previous)) as Any
    }
    
    init(total: Int, page: Int, pageSize: Int, next: Any, previous: Any) {
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.next = next
        self.previous = previous
        self.totalPage = 0
    }
}

extension AppPaginationDTO {
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

class AppHTTPResponse<ValueType>: ListHTTPResponse, SingleHTTPResponse, Decodable where ValueType: Decodable {
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
        case pagination
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decode(Bool.self, forKey: .success)
        do {
            self.message = try container.decode(String.self, forKey: .message)
        } catch {
            self.message = ""
        }
        self.pagination = try? container.decode(AppPaginationDTO.self, forKey: .pagination)
        self.result = try? container.decode(ValueType.self, forKey: .data)
        if self.result == nil {
            do {
                self.results = try container.decode([ValueType].self, forKey: .data)
            } catch {
                self.results = []
            }
        } else {
            self.results = nil
        }
        
        self.errorCode = 0
    }
    
    let errorCode: Int
    let message: String?
    let result: ValueType?
    let results: [ValueType]?
    let pagination: Paginated?
    let success: Bool
}
