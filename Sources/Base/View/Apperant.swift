//
//  Apperant.swift
//  CoreCleanSwiftBase
//
//  Created by Robert Nguyen on 11/20/16.
//  Copyright © 2016 Robert Nguyen. All rights reserved.
//

@objc public protocol Appearant {
    @objc optional func willAppear()
    @objc optional func willReappear()
    @objc optional func didReappear()
    @objc optional func didAppear()
    @objc optional func willDisappear()
    @objc optional func didDisappear()
}
