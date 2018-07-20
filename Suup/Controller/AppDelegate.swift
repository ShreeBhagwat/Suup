// IN GOD WE TRUST//
//  AppDelegate.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    
        if #available(iOS 10, *){
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){(granted, error) in }
            application.registerForRemoteNotifications()
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            
            
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        return true
        
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
      Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBHandler()
    }

    @objc func refreshToken(notification: NSNotification){
        let refreshToken  = InstanceID.instanceID().token()!
        print("*** \(refreshToken) ***")
        FBHandler()
    }
}
func FBHandler(){
 Messaging.messaging().shouldEstablishDirectChannel = true
}


@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}






