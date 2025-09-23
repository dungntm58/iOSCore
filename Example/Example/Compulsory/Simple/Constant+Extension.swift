//
//  Constant.swift
//  Core-CleanSwift_Example
//
//  Created by Robert Nguyen on 3/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

func printDBURL() {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    print(docURL.absoluteString)
}

extension Constant {
    struct Request {
        static let jsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = .current
            formatter.locale = .current
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            return decoder
        }()
    }
}
