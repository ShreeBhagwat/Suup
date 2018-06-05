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
        
        let messageArray = ["First Messsage", "Secondkvj kvhjhjgbdhkzjjvjhvbshjbvibvi j vkln svhbv message", "Third Message"]
        
        cell.messageBody.text = messageArray[indexPath.row]
        
        return cell
    }
    
    
    
    
    //TODO: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
    
    @IBAction func sendButtonPressed(_ sender: Any) {
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
