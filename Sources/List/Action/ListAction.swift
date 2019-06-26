//
//  ListAction.swift
//  CoreCleanSwiftList
//
//  Created by Robert Nguyen on 6/8/19.
//

import CoreCleanSwiftRedux
import CoreCleanSwiftBase

public protocol ListActionType: ErrorActionType {
    static var updateListState: Self { get }
    static var load: Self { get }
}

public protocol PayloadListRequestable {
    var page: Int { get }
    var count: Int { get }
    var isAutoRequestCounting: Bool { get }
    var cancelRunning: Bool { get }
}

public extension PayloadListRequestable {
    func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ListActionType {
        return .init(type: .load, payload: self)
    }
}

public enum Payload {
    public enum List {
        public struct Response<T>: Statable, Equatable where T: Equatable {
            public let data: [T]
            public let pagination: PaginationResponse?
            public let currentPage: Int
            public let count: Int
            public let hasNext: Bool
            public let hasPrevious: Bool
            public let isLoading: Bool

            public init(from response: ListResponse<T>, payload: PayloadListRequestable?) {
                self.data = response.data
                self.pagination = response.pagination
                let page = payload?.page ?? 0
                var count = payload?.count ?? 0
                if payload?.isAutoRequestCounting ?? false {
                    count = response.data.count
                }
                self.currentPage = page
                self.count = count
                self.hasNext = (response.pagination?.hasAfter ?? false) || (count > 0 && response.data.count >= count)
                self.hasPrevious = (response.pagination?.hasBefore ?? false) || (count > 0 && response.data.count >= count)
                self.isLoading = false
            }

            public init(data: [T] = [], pagination: PaginationResponse? = nil, currentPage: Int = 0, count: Int = 0, hasNext: Bool = false, hasPrevious: Bool = false, isLoading: Bool = false) {
                self.data = data
                self.pagination = pagination
                self.currentPage = currentPage
                self.count = count
                self.hasNext = hasNext
                self.hasPrevious = hasPrevious
                self.isLoading = isLoading
            }

            public static func == (lhs: Response<T>, rhs: Response<T>) -> Bool {
                return
                    lhs.isLoading == rhs.isLoading &&
                        lhs.data == rhs.data &&
                        lhs.currentPage == rhs.currentPage &&
                        lhs.count == rhs.count &&
                        lhs.hasNext == rhs.hasNext &&
                        lhs.hasPrevious == rhs.hasPrevious &&
                        lhs.pagination?.total == rhs.pagination?.total &&
                        lhs.pagination?.pageSize == rhs.pagination?.pageSize &&
                        lhs.pagination?.hasBefore == rhs.pagination?.hasBefore &&
                        lhs.pagination?.hasAfter == rhs.pagination?.hasAfter
            }

            public func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ListActionType {
                return .init(type: .updateListState, payload: self)
            }
        }
    }
}
