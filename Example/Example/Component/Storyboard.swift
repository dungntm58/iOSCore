//
//  Storyboard.swift
//  Core-CleanSwift-Example
//
//  Created by Robert Nguyễn on 9/9/18.
//  Copyright © 2018 Robert Nguyễn. All rights reserved.
//

import UIKit
import CoreBase

enum AppStoryboard: String, Storyboard {
    case main = "Main"
}

@MainActor
func getCurrentWindow() -> UIWindow? {
    // iOS 15+ approach
    if #available(iOS 15.0, *) {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    } else {
        // iOS 13-14 approach
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
}