//
//  Message.swift
//  Suup
//
//  Created by Gauri Bhagwat on 04/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class Message:NSObject {
    
  @objc var  fromId:String?
  @objc var  toId:String?
  @objc var  timeStamp:NSNumber?
  @objc var  text:String?
    
   func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}


