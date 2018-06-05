//
//  ChatTableViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]()
    
    
    
    
    //MARK:- IBoutlests
   
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        //TODO: TableView Delegate
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: TextField Delegate
        messageTextField.delegate = self
        
        //TODO: Tapgesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //TODO: Register Message XIB file
        messageTableView.register(UINib(nibName:"CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        messageTableView.separatorStyle = .none
      
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    ////////////////////////////////////////
    //MARK:-tableViewDataSource
    
    

    //TODO: cellForRowAtIndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text! = messageArray[indexPath.row].messageBody
        cell.senderUsername.text! = messageArray[indexPath.row].sender
        cell.profilePicture.image = UIImage(named: "profile")
        
        return cell
    }
    
    
    
    
    //TODO: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //TODO: Declare Tableviwe Tapped here
    
    @objc func tableViewTapped(){
        messageTextField.endEditing(true)
    }
    
    //TODO: Declare configureTableview  here
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    /////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    //TODO:- textFieldDidBeginEditing here:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 330
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: textFieldDidEndEditing here.
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    //////////////////////////////////////////
    //MARK:- sendButtonPressed
    
 
    @IBAction func sendButttonPressed(_ sender: Any) {
        messageTextField.endEditing(true)
        
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
    // Message Database
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDiconary = ["Sender":Auth.auth().currentUser?.phoneNumber,
                               "MessageBody": messageTextField.text!]
        
        messageDB.childByAutoId().setValue(messageDiconary){
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message Saved Successfully!")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    //TODO: create the retrieveMessages method here
    
    func retrieveMessages(){
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    
    /////////////////////////////////////////
    
    //MARK:- Log Out Method
    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
            
        }
        catch {
            print("error: there was a problem logging out")
        }
        
    }
    
    }
