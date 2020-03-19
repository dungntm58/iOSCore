//
//  UserRequest.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 9/13/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import RxSwift
import RxCoreBase
import RxCoreRepository
import Alamofire

class AuthRequest: HTTPRequest, Decoding {
    typealias Response = AppHTTPResponse<AuthDto>
    typealias API = AppAPI
    
    let decoder: JSONDecoder
    
    init() {
        self.decoder = Constant.Request.jsonDecoder
    }
    
    func login(_ options: RequestOption?) -> Observable<Response> {
        execute(api: .login, options: options)
    }
    
    func signup(_ options: RequestOption?) -> Observable<Response> {
        execute(api: .signup, options: options)
    }
}
