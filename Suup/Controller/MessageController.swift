//
//  MessageController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 11/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

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
            let uid = Auth.auth().currentUser?.uid
            print(uid!)
            
            Database.database().reference().child("Users").child(uid!).observe(.value, with: { (snapshot) in
                if snapshot.value is NSNull {
                    print("null")
                }else{
                    
                    if let dictonary = snapshot.value as? [String: AnyObject]{
                        self.navigationItem.title = dictonary["userName"] as? String
                    }
                }
            }, withCancel: nil)
            
            }
        }
    

    
    
    @objc func logOut(){
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
       navigationController?.popToRootViewController(animated: true)
}
}
