//
//  TodoRequest.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import CoreBase
import CoreRequest
import Alamofire

class TodoSingleRequest: IdentifiableHTTPRequest {
    typealias Response = AppHTTPResponse<TodoEntity>
    typealias API = AppAPI
    
    let decoder: JSONDecoder
    
    init() {
        self.decoder = Constant.Request.jsonDecoder
    }
    
    func get(id: String, options: RequestOption? = nil) -> Observable<Response> {
        return execute(api: .getTodos(id: id), options: options)
    }
    
    func delete(id: String, options: RequestOption? = nil) -> Observable<Response> {
        return execute(api: .delete(id: id), options: options)
    }
    
    func create(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        return execute(api: .createTodo, options: value.toLiteralDictionary())
    }
    
    func update(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        return execute(api: .updateTodo(id: value.id), options: value.toLiteralDictionary())
    }
    
    func delete(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        return self.delete(id: value.id, options: options)
    }
    
    #if DEBUG
    static func mockFileName(for api: API, options: RequestOption?, header: HTTPHeaders?) -> String? {
        return nil
    }
    #endif
}

class TodoListRequest: ListModelHTTPRequest {
    typealias Response = AppHTTPResponse<TodoEntity>
    typealias API = AppAPI
    
    let decoder: JSONDecoder
    
    init() {
        self.decoder = Constant.Request.jsonDecoder
    }
    
    func getList(options: RequestOption?) -> Observable<Response> {
        return execute(api: .getTodos(id: nil), options: options)
    }
}
