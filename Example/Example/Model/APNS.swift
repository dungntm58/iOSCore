//
//  APNS.swift
//  Example
//
//  Created by Robert on 8/21/19.
//  Copyright © 2019 Robert Nguyen. All rights reserved.
//

import RxCoreAPNS

struct APNSEvent<ValueType>: APNSEventProtocol {
    let event: String
    let data: ValueType?
}

struct APNSData {
    
}
