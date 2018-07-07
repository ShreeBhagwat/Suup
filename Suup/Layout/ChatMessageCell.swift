//
//  ChatMessageCell.swift
//  Suup
//
//  Created by Gauri Bhagwat on 19/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    var message: Message?{
        didSet{
    if let seconds = message?.timeStamp?.doubleValue {
        let timeStampDate = NSDate(timeIntervalSince1970: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm: a"
        messageTimeStamp.text = dateFormatter.string(from: timeStampDate as Date)
        }
    }
}
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample Text For Now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        
        return tv
    }()
    
//    static let blueColour = UIColor.init(red: (110.0/255.0), green: (242.0/255.0), blue: (244.0/255.0), alpha: 1)
        static let blueColour = UIColor(hexString: "78daf6")
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = blueColour
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageZoom))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }()
        var messageTimeStamp: UILabel = {
        let messageTime = UILabel()
        messageTime.translatesAutoresizingMaskIntoConstraints = false
        messageTime.textColor = UIColor.lightGray
        messageTime.font = UIFont.italicSystemFont(ofSize: 12)
            messageTime.text = "00:00"
    
        
        
        return messageTime
    }()
    
    @objc func imageZoom(tapGesture:UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInImages(startingImageView: imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        addSubview(messageTimeStamp)
        
        //IOS 9 Constraints: x, y , width, height
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        //IOS 9 Constraints: x, y , width, height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        
        //IOS 9 Constraints: x, y , width, height
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: messageTimeStamp.leftAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //MessageTimeStamp Constraints
            messageTimeStamp.leftAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
            messageTimeStamp.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        messageTimeStamp.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
//            messageTimeStamp.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //IOS 9 Constraints: x, y , width, height
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
