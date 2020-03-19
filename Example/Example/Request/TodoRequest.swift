//
//  TodoRequest.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreBase
import RxCoreRepository
import Alamofire

class TodoSingleRequest: IdentifiableSingleHTTPRequest, Decoding {
    typealias Response = AppHTTPResponse<TodoEntity>
    typealias API = AppAPI
    
    let decoder: JSONDecoder
    
    init() {
        self.decoder = Constant.Request.jsonDecoder
    }
    
    func get(id: String, options: RequestOption? = nil) -> Observable<Response> {
        execute(api: .getTodos(id: id), options: options)
    }
    
    func delete(id: String, options: RequestOption? = nil) -> Observable<Response> {
        execute(api: .delete(id: id), options: options)
    }
    
    func create(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        execute(api: .createTodo, options: value.toLiteralDictionary())
    }
    
    func update(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        execute(api: .updateTodo(id: value.id), options: value.toLiteralDictionary())
    }
    
    func delete(_ value: TodoEntity, options: RequestOption? = nil) -> Observable<Response> {
        self.delete(id: value.id, options: options)
    }
    
    #if DEBUG
    static func mockFileName(for api: API, options: RequestOption?, header: HTTPHeaders?) -> String? {
        nil
    }
    #endif
}

class TodoListRequest: ListModelHTTPRequest, Decoding {
    typealias Response = AppHTTPResponse<TodoEntity>
    typealias API = AppAPI
    
    let decoder: JSONDecoder
    
    init() {
        self.decoder = Constant.Request.jsonDecoder
    }
    
    func getList(options: RequestOption?) -> Observable<Response> {
        execute(api: .getTodos(id: nil), options: options)
    }
}
