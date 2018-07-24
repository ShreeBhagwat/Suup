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
    
    //Getting Device ID
    let userDeviceId = UIDevice.current.identifierForVendor?.uuidString
    
    func manageConnections(UserId: String){
        
        // Create Reference To The Database
//       let myConnectionRef = Database.database().reference(withPath: "Users/\(UserId)/connections/\(self.userDeviceId)")
        let myConnectionRef = Database.database().reference().child("User").child(UserId).child("connection").child(self.userDeviceId!)
        myConnectionRef.child("online").setValue(true)
        myConnectionRef.child("last_online").setValue(NSNumber(value: Int(NSDate().timeIntervalSince1970)))
        
        // Observe For User logged in or logged out
        myConnectionRef.observe(.value) { (snapshot) in
            guard let connected = snapshot.value as? Bool, connected else {return}
        }
    }
    
    
}
