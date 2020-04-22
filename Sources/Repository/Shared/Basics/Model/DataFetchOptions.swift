//
//  DataRequestOption.swift
//  CoreBase
//
//  Created by Robert Nguyen on 1/16/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

public protocol RequestOption {
    var parameters: [String: Any]? { get }
}

extension Dictionary: RequestOption where Key == String {
    public var parameters: [String: Any]? { self }
}

public protocol FetchOptions {
    var requestOptions: RequestOption? { get }
    var repositoryOptions: RepositoryOption { get }
    var storeFetchOptions: DataStoreFetchOption { get }
}

public enum RepositoryOption {
    case ignoreDataStore
    case forceRefresh(ignoreDataStoreFailure: Bool)
    case `default`
}

public enum DataStoreFetchOption {
    public enum Sorting {
        case asc(property: String)
        case desc(property: String)
        case automatic
    }

    case automatic
    case predicate(_ predicate: NSPredicate, limit: Int, sorting: [Sorting], validate: Bool)
    case page(_ page: Int, size: Int, predicate: NSPredicate?, sorting: [Sorting], validate: Bool)
}

public func makeFetchOptions(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) -> FetchOptions {
    InternalFetchOptions(requestOptions: requestOptions, repositoryOptions: repositoryOptions, storeFetchOptions: storeFetchOptions)
}

extension Encodable {
    public func toDictionary(withEncoder encoder: JSONEncoder = .init()) -> [String: Any]? {
        switch self {
        case let dict as [String: Any]:
            return dict
        default:
            do {
                let data = try encoder.encode(self)
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            } catch {
                return nil
            }
        }
    }
}

extension Encodable where Self: RequestOption {
    public var parameters: [String: Any]? { toDictionary() }
}
