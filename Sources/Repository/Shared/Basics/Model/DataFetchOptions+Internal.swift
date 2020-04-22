//
//  FetchOptions+Internal.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

struct InternalFetchOptions: FetchOptions {
    let requestOptions: RequestOption?
    let repositoryOptions: RepositoryOption
    let storeFetchOptions: DataStoreFetchOption

    init(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) {
        self.requestOptions = requestOptions
        self.repositoryOptions = repositoryOptions
        self.storeFetchOptions = storeFetchOptions
    }
}

extension RequestOption {
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(requestOptions: self)
    }
}

extension RepositoryOption {
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(repositoryOptions: self)
    }
}

extension DataStoreFetchOption {
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(storeFetchOptions: self)
    }
}
