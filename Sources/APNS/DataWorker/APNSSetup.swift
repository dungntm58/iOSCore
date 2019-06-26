//
//  APNSSetup.swift
//  CoreCleanSwiftAPNS
//
//  Created by Robert Nguyen on 3/31/19.
//

import UserNotifications

public class APNSConfig {
    @available(iOS 10.0, *)
    lazy private(set) var userNotificationCenter = UNUserNotificationCenter.current()

    @available(iOS 10.0, *)
    lazy private(set) var authorizationOptions: UNAuthorizationOptions = []

    private let userNotificationType: UIUserNotificationType
    private let categories: Set<UIUserNotificationCategory>?

    @available(iOS 10.0, *)
    lazy private var userNotificationCenterDelegate: UNUserNotificationCenterDelegate? = nil

    @available(iOS 10.0, *)
    init(options: UNAuthorizationOptions, userNotificationCenterDelegate: UNUserNotificationCenterDelegate?) {
        self.userNotificationType = []
        self.categories = nil
        self.authorizationOptions = options
        self.userNotificationCenterDelegate = userNotificationCenterDelegate
    }

    init(settings: UIUserNotificationType, categories: Set<UIUserNotificationCategory>?) {
        self.userNotificationType = settings
        self.categories = categories
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            userNotificationCenter.requestAuthorization(options: authorizationOptions) {
                granted, error in
                if granted {
                    application.registerForRemoteNotifications()
                }
            }

            // For iOS 10 display notification (sent via APNS)
            userNotificationCenter.delegate = userNotificationCenterDelegate
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: userNotificationType, categories: categories)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    public static func registerForRemoteNotifications(_ application: UIApplication, settings: UIUserNotificationType, categories: Set<UIUserNotificationCategory>?) {
        APNSConfig(settings: settings, categories: categories).registerForRemoteNotifications(application)
    }

    @available(iOS 10.0, *)
    public static func registerForRemoteNotifications(_ application: UIApplication, options: UNAuthorizationOptions, userNotificationCenterDelegate: UNUserNotificationCenterDelegate?) {
        APNSConfig(options: options, userNotificationCenterDelegate: userNotificationCenterDelegate).registerForRemoteNotifications(application)
    }
}
