//
//  DataRequestOption.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 1/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

public protocol DataFetchOptions {
    var requestOptions: RequestOption? { get }
    var repositoryOptions: RepositoryOption { get }
    var storeFetchOptions: DataStoreFetchOption { get }
}

struct DefaultDataFetchOptions: DataFetchOptions {
    let requestOptions: RequestOption?
    let repositoryOptions: RepositoryOption
    let storeFetchOptions: DataStoreFetchOption

    init(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) {
        self.requestOptions = requestOptions
        self.repositoryOptions = repositoryOptions
        self.storeFetchOptions = storeFetchOptions
    }
}

public protocol RequestOption {
    var parameters: [String: Any]? { get }
}

public extension RequestOption {
    func toDataFetchOptions() -> DataFetchOptions {
        return DefaultDataFetchOptions(requestOptions: self)
    }
}

public enum RepositoryOption {
    case ignoreDataStore
    case forceRefresh(ignoreFailureDataStore: Bool)
    case `default`

    public func toDataFetchOptions() -> DataFetchOptions {
        return DefaultDataFetchOptions(repositoryOptions: self)
    }
}

public enum DataStoreFetchOption {
    case automatic
    case predicate(_ predicate: NSPredicate, limit: Int, sorting: Sorting, validate: Bool)
    case page(_ page: Int, size: Int, predicate: NSPredicate?, sorting: Sorting, validate: Bool)

    public func toDataFetchOptions() -> DataFetchOptions {
        return DefaultDataFetchOptions(storeFetchOptions: self)
    }
}

public enum Sorting {
    case asc(property: String)
    case desc(property: String)
    case automatic
}
