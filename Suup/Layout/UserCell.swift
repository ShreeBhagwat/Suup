//
//  UserCell.swift
//  Suup
//
//  Created by Gauri Bhagwat on 16/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
class UserCell : UITableViewCell {
    
    var message : Message? {
        didSet{
            if let toId = message?.toId {
                let ref = Database.database().reference().child("Users").child(toId)
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        self.textLabel?.text = dictionary["userName"] as? String
                        
                        if  let profileImageUrl = dictionary["profileImageUrl"]{
                            self.profileImageView.loadImageFromCache(urlString: profileImageUrl as! String)
                        }
                    }
                    
                }, withCancel: nil)
            }
            
           detailTextLabel?.text = message?.text
            
            if let seconds = message?.timeStamp?.doubleValue {
              let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm: a"
                timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
            }
            
           
     
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: ((textLabel?.frame.origin.y)!-2), width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 64, y: ((detailTextLabel?.frame.origin.y)!+2), width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var timeLabel:UILabel = {
        let lable = UILabel()
        lable.text = "HH:MM:SS"
        lable.font = UIFont.systemFont(ofSize: 12)
        lable.textColor = UIColor.darkGray
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //Constraints X, Y, Width, Height
        profileImageView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Constraints X, Y, Width, Height
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


