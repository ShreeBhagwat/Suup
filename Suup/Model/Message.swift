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
  @objc  var imageUrl:String?
  @objc  var imageHeight:NSNumber?
  @objc  var imageWidth:NSNumber?
  @objc var DeviceId:String?
  @objc var audioUrl:String?
    @objc var videoStorageUrl:String?
    
   func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    init(dictionary:[String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        DeviceId = dictionary["DeviceId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        audioUrl = dictionary["audioUrl"] as? String
        videoStorageUrl = dictionary["videoStorageUrl"] as? String
    }
}


