//
//  AppDelegate.swift
//  Pushnofify
//
//  Created by Anil Kumar on 28/11/18.
//  Copyright © 2018 AIT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    var appIsStarting = Bool()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
   

        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        requestNotificationAuthorization(application: application)
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] {
            NSLog("[RemoteNotification] applicationState: \(applicationStateString) didFinishLaunchingWithOptions for iOS9: \(userInfo)")
            //TODO: Handle background notification
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    var applicationStateString: String {
        if UIApplication.shared.applicationState == .active {
            return "active"
        } else if UIApplication.shared.applicationState == .background {
            return "background"
        }else {
            return "inactive"
        }
    }
    
    func requestNotificationAuthorization(application: UIApplication) {
         UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
}
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
    }
    
    // iOS9, called when presenting notification in foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        
        if UIApplication.shared.applicationState == .active {
            print(userInfo)
        } else {
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState willPresent : \(applicationStateString) willPresentNotification: \(userInfo)")
        let aps = userInfo[AnyHashable("aps")] as? NSDictionary
        print(aps!)
        let alert = aps?.value(forKey: "alert") as! String
        let badge = aps?.value(forKey: "badge") as! Int
        UIApplication.shared.applicationIconBadgeNumber = badge
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState withCompletionHandler: \(applicationStateString) didReceiveResponse: \(userInfo)")
        completionHandler()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("userinfo in background mode on-\(userInfo)")
        completionHandler(UIBackgroundFetchResult.newData)
    }        
  
    
}
