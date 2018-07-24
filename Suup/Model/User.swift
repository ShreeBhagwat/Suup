//
//  User.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/07/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
class User : NSObject {
    @objc var connections:String?
    @objc var userDeviceId:String?
    @objc var last_online:NSNumber?
    var online:Bool?
}
