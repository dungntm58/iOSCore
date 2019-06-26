//
//  AppInteractor.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyen on 1/9/19.
//  Copyright © 2019 Robert Nguyễn. All rights reserved.
//

import RxSwift
import Alamofire
import CoreBase

class AppInteractor {
    let disposeBag: DisposeBag
    
    init() {
        disposeBag = DisposeBag()
    }
    
    func onError(_ error: Error) {}
}

extension Dictionary: RequestOption where Key == String {
    public var parameters: Parameters? {
        return self
    }
}
