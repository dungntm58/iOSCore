//
//  Observable+Response.swift
//  CoreRepository-Rx
//
//  Created by Robert on 09/03/2021.
//

import RxSwift
import Alamofire

extension ObservableType where Element == AFDataResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Observable<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == AFDataResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Single<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}

extension PrimitiveSequenceType where Trait == MaybeTrait, Element == AFDataResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Maybe<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}

extension ObservableType where Element == AFDownloadResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Observable<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == AFDownloadResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Single<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}

extension PrimitiveSequenceType where Trait == MaybeTrait, Element == AFDownloadResponse<Data> {
    public func map<D>(_ type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) -> Maybe<D> where D: Decodable {
        map { try trySerialize(from: $0, to: type, atKeyPath: keyPath, decoder: decoder) }
    }
}
