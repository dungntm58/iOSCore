//
//  AppModelHTTPRequest.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import Alamofire
import RxSwift
import CoreRequest
import CoreBase

extension HTTPRequest {
    var defaultHeaders: HTTPHeaders? {
        return [
            "Authorization": AppPreferences.instance.token ?? ""
        ]
    }
    
    var environment: RequestEnvironment {
        #if DEBUG
        return AppEnvironment.development
        #else
        return AppEnvironment.production
        #endif
    }
}

extension RequestOption {
    func merge(with parameters: Parameters) -> RequestOption {
        return self
    }
}

enum AppEnvironment: RequestEnvironment {
    case development
    case production
    
    var config: RequestConfiguration {
        return self
    }
}

extension AppEnvironment: RequestConfiguration {
    var baseUrl: String {
        return "https://uetcc-todo-app.herokuapp.com"
    }
    
    var versions: [String] {
        return []
    }
}

enum AppAPI: RequestAPI {
    case login
    case signup
    case getTodos(id: String?)
    case delete(id: String)
    case createTodo
    case updateTodo(id: String)
    
    var method: HTTPMethod {
        switch self {
        case .login, .signup, .createTodo:
            return .post
        case .updateTodo:
            return .put
        case .getTodos:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var endPoint: String {
        switch self {
        case .login:
            return "/login"
        case .signup:
            return "/register"
        case .getTodos(let id):
            if let id = id {
                return "/todos/\(id)"
            }
            return "/todos"
        case .delete(let id), .updateTodo(let id):
            return "/todos/\(id)"
        case .createTodo:
            return "/todos"
        }
    }
}
