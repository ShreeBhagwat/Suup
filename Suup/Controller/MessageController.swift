//
//  MessageController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 11/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        
        let image = UIImage(named:"newMessageIcon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(newMessage))
        
        
            
        checkIfUserLoggedIn()
  
}
   
    
    
    @objc func newMessage(){
        let newMessageViewController = NewMessageViewController()
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
                    self.navigationItem.title = dictonary["userName"] as? String
                    
                    let user = Users()
                    user.setValuesForKeys(dictonary)
                    self.navBarWithUser(user: user)
                }
            }
        }, withCancel: nil)
    }
    
    
    func navBarWithUser(user: Users){
  
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
        
        var button = UIButton(type: .custom) as UIButton
     
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(showChatLogController), for: UIControlEvents.touchUpInside)
        self.navigationItem.titleView = button
    }
    
    @objc func showChatLogController(){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)

    }
   
    
    @objc func logOut(){
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
