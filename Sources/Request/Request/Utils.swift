//
//  Utils.swift
//  CoreCleanSwiftRequest
//
//  Created by Robert Nguyen on 4/23/19.
//

#if DEBUG
enum Utils {
    static func readTextFile(name: String, type: String = "") throws -> String {
        guard let filepath = Bundle.main.path(forResource: name, ofType: type) else {
            throw NSError(domain: "RequestUtils", code: 3456, userInfo: [
                NSLocalizedDescriptionKey: "File with name \(name) not found"
            ])
        }
        return try String(contentsOfFile: filepath)
    }

    static func readFile(name: String, type: String = "") throws -> Data {
        guard let filepath = Bundle.main.path(forResource: name, ofType: type),
            let url = URL(string: filepath) else {
            throw NSError(domain: "RequestUtils", code: 3456, userInfo: [
                NSLocalizedDescriptionKey: "File with name \(name) not found"
            ])
        }
        return try Data(contentsOf: url)
    }
}
#endif
