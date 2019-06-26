//
//  Util+Extension.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public func += <K, V> ( left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

public func + <K, V>(lhs: [K:V], rhs: [K:V]) -> [K:V] {
    var res: [K:V] = lhs
    res += rhs
    return res
}

public struct Util {
    public static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    public static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    public static func makeDataFetchOptions(requestOptions: RequestOption? = nil, repositoryOptions: RepositoryOption = .default, storeFetchOptions: DataStoreFetchOption = .automatic) -> DataFetchOptions {
        return DefaultDataFetchOptions(requestOptions: requestOptions, repositoryOptions: repositoryOptions, storeFetchOptions: storeFetchOptions)
    }
}
