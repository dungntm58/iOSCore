//
//  Payload.swift
//  RxCoreRedux
//
//  Created by Robert on 8/10/19.
//

import RxCoreRepository

public enum Payload {
    public enum List {
        public struct Response<T>: Statable, Equatable where T: Equatable {
            public let data: [T]
            public let pagination: PaginationDTO?
            public let currentPage: Int
            public let pageSize: Int
            public let hasNext: Bool
            public let hasPrevious: Bool
            public let isLoading: Bool

            public init(from response: ListDTO<T>, payload: PayloadListRequestable?) {
                self.data = response.data
                self.pagination = response.pagination
                let page = payload?.page ?? 0
                var count = payload?.count ?? 0
                if payload?.isAutoRequestCounting ?? false {
                    count = response.data.count
                }
                self.currentPage = page
                self.pageSize = count
                self.hasNext = (response.pagination?.hasNext ?? false) || (count > 0 && response.data.count >= count)
                self.hasPrevious = (response.pagination?.hasPrevious ?? false) || (count > 0 && response.data.count >= count)
                self.isLoading = false
            }

            public init(data: [T] = [], pagination: PaginationDTO? = nil, currentPage: Int = 0, pageSize: Int = 0, hasNext: Bool = false, hasPrevious: Bool = false, isLoading: Bool = false) {
                self.data = data
                self.pagination = pagination
                self.currentPage = currentPage
                self.pageSize = pageSize
                self.hasNext = hasNext
                self.hasPrevious = hasPrevious
                self.isLoading = isLoading
            }

            public static func == (lhs: Response<T>, rhs: Response<T>) -> Bool {
                lhs.isLoading == rhs.isLoading &&
                    lhs.data == rhs.data &&
                    lhs.currentPage == rhs.currentPage &&
                    lhs.pageSize == rhs.pageSize &&
                    lhs.hasNext == rhs.hasNext &&
                    lhs.hasPrevious == rhs.hasPrevious &&
                    lhs.pagination?.total == rhs.pagination?.total &&
                    lhs.pagination?.pageSize == rhs.pagination?.pageSize &&
                    lhs.pagination?.hasPrevious == rhs.pagination?.hasPrevious &&
                    lhs.pagination?.hasNext == rhs.pagination?.hasNext
            }

            public func toAction<Action>() -> Action where Action: Actionable, Action.ActionType: ListActionType {
                .init(type: .updateListState, payload: self)
            }
        }
    }
}
