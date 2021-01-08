//
//  RequestParams.swift
//  Example
//
//  Created by Dung Nguyen on 11/6/20.
//  Copyright © 2020 Robert Nguyen. All rights reserved.
//

import CoreRedux

extension Payload.List {
    struct Request: PayloadListRequestable, CustomStringConvertible {
        let page: Int
        let count: Int
        let isAutoRequestCounting: Bool
        let cancelRunning: Bool
        
        init(page: Int, count: Int = 10, isAutoRequestCounting: Bool = true, cancelRunning: Bool) {
            self.page = page
            self.count = count
            self.isAutoRequestCounting = isAutoRequestCounting
            self.cancelRunning = cancelRunning
        }
        
        var description: String {
            """
            Request(
                page: \(page),
                count: \(count),
                isAutoRequestCounting: \(isAutoRequestCounting),
                cancelRunning: \(cancelRunning)
            )
            """
        }
    }
}

extension Payload.List.Response: CustomStringConvertible {
    public var description: String {
        """
        Response<\(String(describing: T.self))>(
            data: [\(data.map(String.init(describing:)).joined(separator: "  \n"))],
            pagination: \(pagination.map(String.init(describing:)) ?? "nil"),
            currentPage: \(currentPage),
            pageSize: \(pageSize),
            hasNext: \(hasNext),
            hasPrevious: \(hasPrevious),
            isLoading: \(isLoading)
        )
        """
    }
}
