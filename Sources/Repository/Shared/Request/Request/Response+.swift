//
//  Response+.swift
//  CoreRepository-Rx
//
//  Created by Robert on 09/03/2021.
//

import Alamofire

func trySerialize<D>(from data: Data, to type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) throws -> D where D: Decodable {
    guard let keyPath = keyPath else {
        return try decoder.decode(type, from: data)
    }
    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary else {
        throw NSError(domain: "DecodingError", code: -999, userInfo: [
            NSLocalizedDescriptionKey: "Cannot decode json with keyPath \(keyPath)"
        ])
    }
    guard let jsonObject = json.value(forKeyPath: keyPath), JSONSerialization.isValidJSONObject(jsonObject) else {
        throw NSError(domain: "DecodingError", code: -999, userInfo: [
            NSLocalizedDescriptionKey: "Cannot decode json with keyPath \(keyPath)"
        ])
    }
    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
    return try decoder.decode(type, from: jsonData)
}

func trySerialize<D, Failure>(from response: DataResponse<Data, Failure>, to type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) throws -> D where D: Decodable, Failure: Error {
    switch response.result {
    case .success(let data):
        return try trySerialize(from: data, to: type, atKeyPath: keyPath, decoder: decoder)
    case .failure(let error):
        throw error
    }
}

func trySerialize<D, Failure>(from response: DownloadResponse<Data, Failure>, to type: D.Type, atKeyPath keyPath: String? = nil, decoder: JSONDecoder = .init()) throws -> D where D: Decodable, Failure: Error {
    switch response.result {
    case .success(let data):
        return try trySerialize(from: data, to: type, atKeyPath: keyPath, decoder: decoder)
    case .failure(let error):
        throw error
    }
}
