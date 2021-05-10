//
//  Response+Combine.swift
//  CoreRepository-Combine
//
//  Created by Robert on 09/03/2021.
//

import Combine
import Alamofire

// swiftlint:disable force_try
extension Publisher where Output == Data {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.Map<Self, D> where D: Decodable {
        Publishers.Map(upstream: self) {
            try! trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }

    public func tryMap<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.TryMap<Self, D> where D: Decodable {
        Publishers.TryMap(upstream: self) {
            try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }
}

extension Publisher where Output == AFDataResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.Map<Self, D> where D: Decodable {
        Publishers.Map(upstream: self) {
            try! trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }

    public func tryMap<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.TryMap<Self, D> where D: Decodable {
        Publishers.TryMap(upstream: self) {
            try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }
}

extension Publisher where Output == AFDownloadResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.Map<Self, D> where D: Decodable {
        Publishers.Map(upstream: self) {
            try! trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }

    public func tryMap<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Publishers.TryMap<Self, D> where D: Decodable {
        Publishers.TryMap(upstream: self) {
            try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder)
        }
    }
}
// swiftlint:enable force_try
