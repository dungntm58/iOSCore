//
//  Storyboard.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import RxCoreBase

enum AppStoryboard: String, Storyboard {
    case main = "Main"
    
    var name: String { rawValue }
    
    var bundle: Bundle? { nil }
}
