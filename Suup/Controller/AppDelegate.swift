// IN GOD WE TRUST//
// God Is Great//

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
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
   static var DeviceId = String()
   static let ServerKey = "AAAASBF12L8:APA91bGnBjXfJYat3OuTZ_A4hOnXxKrtSwOtyx2eXn5qMGFpVUQ7e-8tunF_-TQjsA1PqxPQu-GMhAPVqEK9U81iVSpUhxFovSrDmmM3ybIPxj70i-vZdLRP2vEJ6c2ZvJ1zCybU0u_p"
    static let Notification_URL = "https://gcm-http.googleapis.com/gcm/send"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
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
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
      Messaging.messaging().shouldEstablishDirectChannel = false
        let uid = Auth.auth().currentUser?.uid
        UsersPresence().userOffline(UserId: uid!)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFCM()
        let uid = Auth.auth().currentUser?.uid
        UsersPresence().userOnline(UserId: uid!)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
       let newToken =  InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                connectToFCM()
                print("Remote instance ID token: \(result.token)")
                AppDelegate.DeviceId = result.token
            }
        }
    }
}


func connectToFCM(){
 Messaging.messaging().shouldEstablishDirectChannel = true
    
}
func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    Messaging.messaging().apnsToken = deviceToken as Data

}


@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notification = notification.request.content.body
        completionHandler(.alert)
    }
}






