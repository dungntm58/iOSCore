//
//  Apperant.swift
//  RxCoreBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

@objc public protocol Appearant {
    @objc optional func didLoad()
    @objc optional func willAppear(_ animated: Bool)
    @objc optional func willReappear(_ animated: Bool)
    @objc optional func didAppear(_ animated: Bool)
    @objc optional func didReappear(_ animated: Bool)
    @objc optional func willDisappear(_ animated: Bool)
    @objc optional func didDisappear(_ animated: Bool)
}
