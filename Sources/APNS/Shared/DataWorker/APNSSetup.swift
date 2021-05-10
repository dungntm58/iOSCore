//
//  APNSSetup.swift
//  CoreCleanSwiftAPNS
//
//  Created by Robert Nguyen on 3/31/19.
//

import UserNotifications

public class APNSConfig {
    lazy private(set) var userNotificationCenter = UNUserNotificationCenter.current()

    lazy private(set) var authorizationOptions: UNAuthorizationOptions = []

    lazy private var userNotificationCenterDelegateImpl: UNUserNotificationCenterDelegate? = nil

    init(options: UNAuthorizationOptions, userNotificationCenterDelegate: UNUserNotificationCenterDelegate?) {
        self.authorizationOptions = options
        self.userNotificationCenterDelegateImpl = userNotificationCenterDelegate
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        userNotificationCenter
            .requestAuthorization(options: authorizationOptions) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }

        // For iOS 10 display notification (sent via APNS)
        userNotificationCenter.delegate = userNotificationCenterDelegateImpl

        application.registerForRemoteNotifications()
    }

    @available(iOS 10.0, *)
    public static func registerForRemoteNotifications(_ application: UIApplication, options: UNAuthorizationOptions, userNotificationCenterDelegate: UNUserNotificationCenterDelegate?) {
        APNSConfig(options: options, userNotificationCenterDelegate: userNotificationCenterDelegate).registerForRemoteNotifications(application)
    }
}
