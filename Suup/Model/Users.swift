//
//  Users.swift
//  Suup
//
//  Created by Gauri Bhagwat on 11/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
import Firebase
import Contacts

class Users: NSObject {
    
  @objc  var id:String?
  @objc  var phoneNumber:String?
  @objc  var userName:String?
  @objc  var UserId:String?
  @objc var DeviceId:String?
  @objc  var profileImageUrl:String?
    @objc  var online = Bool()
    @objc var typing = Bool()
    @objc var last_online:NSNumber?


}

