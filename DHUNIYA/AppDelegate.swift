//
//  AppDelegate.swift
//  DHUNIYA
//
//  Created by Lifeboat on 21/11/25.
//
import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseCrashlytics
import UserNotifications
import IQKeyboardManagerSwift
import Kingfisher
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        configureFirebase()
        
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = []
        

        MobileAds.shared.start { status in
            print("🔥 Google Mobile Ads SDK initialized")
        }

        setupPushNotifications(application)

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true

        return true
    }

    private func configureFirebase() {
        guard let plistName = Bundle.main.object(forInfoDictionaryKey: "FirebasePlistFile") as? String,
              let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) else {
            fatalError("🔥 Could not load Firebase plist file from Info.plist")
        }

        FirebaseApp.configure(options: options)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    }

    private func setupPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
        
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {}
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔥 FCM Token:", fcmToken ?? "")
    }
}
