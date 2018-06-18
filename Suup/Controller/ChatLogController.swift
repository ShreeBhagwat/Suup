//
//  ChatLogController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 15/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate {
    var user: Users? {
        didSet{
            navigationItem.title = user?.userName
        }
    }
   lazy var inputTextFiled : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.backgroundColor = UIColor.white
        
        setUpInputComponents()
    }
    
    
    func setUpInputComponents(){
        let containerView = UIView()
      
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // Constraints x,y,width,height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendbutton = UIButton(type: .system)
        sendbutton.setTitle("Send", for: .normal)
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
        sendbutton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        containerView.addSubview(sendbutton)
        // Constraints x,y,width,height
        sendbutton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendbutton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendbutton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendbutton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        
//        let inputTextField = UITextField()
//        inputTextField.placeholder = "Enter Message..."
//        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextFiled)
        
        //Constraints x,y,width,height
        inputTextFiled.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:8).isActive = true
        inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextFiled.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
        inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.gray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        //Constraints X,Y,Width,Height
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    
    }
    
    @objc func sendButtonPressed(){
       let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
//        let date = NSDate()
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = "dd-MM-YYYY hh:mm:a"
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["text":inputTextFiled.text!,"toId": toId,"fromId": fromId,"timeStamp":timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            let recipientUsersMessageRef = Database.database().reference().child("user-messages").child(toId)
            recipientUsersMessageRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed()
        return true
    }
    
}
