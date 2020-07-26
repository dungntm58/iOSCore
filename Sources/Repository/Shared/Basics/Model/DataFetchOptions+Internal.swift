//
//  FetchOptions+Internal.swift
//  CoreBase
//
//  Created by Robert on 8/10/19.
//

@frozen
@usableFromInline
struct InternalFetchOptions: FetchOptions {
    @usableFromInline
    let requestOptions: RequestOption?
    @usableFromInline
    let repositoryOptions: RepositoryOption
    @usableFromInline
    let storeFetchOptions: DataStoreFetchOption

    @usableFromInline
    init(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) {
        self.requestOptions = requestOptions
        self.repositoryOptions = repositoryOptions
        self.storeFetchOptions = storeFetchOptions
    }
}

extension RequestOption {
    @inlinable
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(requestOptions: self)
    }
}

extension RepositoryOption {
    @inlinable
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(repositoryOptions: self)
    }
}

extension DataStoreFetchOption {
    @inlinable
    public func toFetchOptions() -> FetchOptions {
        InternalFetchOptions(storeFetchOptions: self)
    }
}
