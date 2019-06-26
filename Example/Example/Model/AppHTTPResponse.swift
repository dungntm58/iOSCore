//
//  HTTPResponse.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import CoreBase
import CoreRequest

struct AppPaginationResponse: PaginationResponse, Decodable {
    let total: Int
    let pageSize: Int
    let after: Any
    let before: Any
    
    enum CodingKeys: CodingKey {
        case total
        case pageSize
        case after
        case before
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Int.self, forKey: .total)
        pageSize = try container.decode(Int.self, forKey: .pageSize)
        after = (try? container.decode(Int.self, forKey: .after)) as Any
        before = (try? container.decode(Int.self, forKey: .before)) as Any
    }
    
    init(total: Int, pageSize: Int, after: Any, before: Any) {
        self.total = total
        self.pageSize = pageSize
        self.after = after
        self.before = before
    }
}

class AppHTTPResponse<ValueType>: ListHTTPResponse, SingleHTTPResponse where ValueType: Decodable {
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
        self.pagination = try? container.decode(AppPaginationResponse.self, forKey: .pagination)
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
    let message: String
    let result: ValueType?
    let results: [ValueType]?
    let pagination: (PaginationResponse & Decodable)?
    let success: Bool
}
