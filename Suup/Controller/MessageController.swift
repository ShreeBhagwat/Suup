//
//  MessageController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 11/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Contacts

class MessageController: UITableViewController, UINavigationControllerDelegate {
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        
        let image = UIImage(named:"newMessageIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(newMessage))
        
        checkIfUserLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
//        observeMessages()
        observeUserMessage()
    
}
    var messages = [Message]()
    var messageDictionary = [String:Message]()
    
    func observeUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
        
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                ref.keepSynced(true)
            })
        }, withCancel: nil)
    }
   
    private func fetchMessageWithMessageId(messageId:String){
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId(){
                    self.messageDictionary[chatPartnerId] = message
                    
                }
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.reloadTableMethod), userInfo: nil, repeats: false)
    }
    
    
    var timer:Timer?
    
    @objc func reloadTableMethod(){
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell
       
        let message = messages[indexPath.row]
        cell?.message = message
        
        return cell!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {return}
        let ref = Database.database().reference().child("Users").child(chatPartnerId)
        ref .observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
            let user = Users()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatLogController(user: user)
        }, withCancel: nil)
        
    }
    @objc func newMessage(){
        let newMessageViewController = NewMessageViewController()
        newMessageViewController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logOut), with: nil, afterDelay: 0)
        } else {
            
            fetchUser()
            }
        }
    

    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else {
        return
        }
        Database.database().reference().child("Users").child(uid).observe(.value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("null")
            }else{
                
                if let dictonary = snapshot.value as? [String: AnyObject]{
                    print("\(snapshot.value)")
                    self.navigationItem.title = dictonary["userName"] as? String
                    
                    let user = Users()
                    user.setValuesForKeys(dictonary)
                   
                    print(dictonary)
                    self.navBarWithUser(user: user)
                }
            }
        }, withCancel: nil)
    }
    
    
    func navBarWithUser(user: Users){
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessage()
        let titleView = UILabel()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 500)
//        titleView.backgroundColor = UIColor.blue
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl{
             profileImageView.loadImageFromCache(urlString: profileImageUrl)
        }
       titleView.addSubview(profileImageView)
       
        
        //Constraints
        //x,y,width,height constraints.
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        titleView.addSubview(nameLabel)
        nameLabel.text = user.userName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //Constraints
        //X,Y,
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        
        self.navigationItem.titleView = titleView
        
//        var button = UIButton(type: .custom) as UIButton
//
//        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        button.backgroundColor = UIColor.red
//        button.addTarget(self, action: #selector(showChatLogController), for: UIControlEvents.touchUpInside)
//        self.navigationItem.titleView = button
    }
    
    @objc func showChatLogController(user: Users){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)

    }
   
    
    @objc func logOut(){
        let user = Auth.auth().currentUser
        
        let myConnectionRef = Database.database().reference().child("User").child((user?.uid)!).child("connection").child(UsersPresence().userDeviceId!)
        myConnectionRef.child("online").setValue(false)
        myConnectionRef.child("last_online").setValue(NSNumber(value: Int(NSDate().timeIntervalSince1970)))
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let profileviewController = ProfileViewController()
        profileviewController.messageController = self
       navigationController?.popToRootViewController(animated: true)
}
}
