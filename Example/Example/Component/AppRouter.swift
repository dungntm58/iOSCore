//
//  AppRouter.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase

//extension Scene {
//    var router: Routable {
//        get {
//            return CleanRouter.shared
//        }
//    }
//
//    var window: UIWindow? {
//        get {
//            return UIApplication.shared.keyWindow
//        }
//    }
//}
//
//extension UIViewController {
//    var router: Routable {
//        return CleanRouter.shared
//    }
//}

enum AppStoryboard: String, Storyboard {
    case main = "Main"
    
    var name: String {
        return rawValue
    }
    
    var bundle: Bundle? {
        return nil
    }
}
