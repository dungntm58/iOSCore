//
//  DataStore+Error.swift
//  CoreRepository
//
//  Created by Robert on 8/10/19.
//

public enum DataStoreError: Error, LocalizedError {
    case storeFailure
    case invalidParam(_ param: String)
    case notFound
    case saveFailure
    case updateFailure
    case lookForIDFailure
    case unknown

    public var errorDescription: String? {
        switch self {
        case .storeFailure:
            return "Something's wrong with store"
        case .invalidParam(let param):
            return "Invalid params \(param)"
        case .notFound:
            return "Value not found"
        case .saveFailure:
            return "Failed to save"
        case .updateFailure:
            return "Failed to update"
        case .lookForIDFailure:
            return "Failed to find id"
        case .unknown:
            return "Unknown error"
        }
    }
}
