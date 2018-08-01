//
//  UsersPresence.swift
//  Suup
//
//  Created by Gauri Bhagwat on 23/07/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


class UsersPresence : NSObject{
    func userOnline(UserId: String){
        let myConnectionRef = Database.database().reference().child("Users").child(UserId)
        myConnectionRef.child("online").setValue(true)
//        myConnectionRef.child("last_online").setValue(Date().timeIntervalSince1970)
        myConnectionRef.child("last_online").setValue(NSNumber(value: Int(NSDate().timeIntervalSince1970)))
 
    }
    
    func userOffline(UserId: String){
        let myConnectionRef = Database.database().reference().child("Users").child(UserId)
        myConnectionRef.child("online").setValue(false)
//        myConnectionRef.child("last_online").setValue(Date().timeIntervalSince1970)
        myConnectionRef.child("last_online").setValue(NSNumber(value: Int(NSDate().timeIntervalSince1970)))
        myConnectionRef.child("online").onDisconnectSetValue(false)

    }
    
    
    func checkUserStatus(userid:String){
        let myConnectionRef = Database.database().reference().child("Users").child(userid)
        myConnectionRef.child("DeviceId").setValue(AppDelegate.DeviceId)
        myConnectionRef.child("online").setValue(true)
        myConnectionRef.child("typing").setValue(false)
//        myConnectionRef.child("last_online").setValue(Date().timeIntervalSince1970)
        myConnectionRef.child("last_online").setValue(NSNumber(value: Int(NSDate().timeIntervalSince1970)))
//        myConnectionRef.child("online").onDisconnectSetValue(false)
        
        // Observe For User logged in or logged out
        myConnectionRef.observe(.value) { (snapshot) in
            let connected = snapshot.value as? Bool
            if connected != nil && connected! {
                print("Connected")
            } else {
                print("Not connected")
            }
        }
    }


    
}
