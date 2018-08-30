//
//  ContactsViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 28/08/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
import Firebase
import Contacts
import SVProgressHUD
import ChameleonFramework

class ContactsViewController : UITableViewController,UINavigationControllerDelegate{
    var items = [UIBarButtonItem]()
    let cellId1 = "cellId1"
    let cellId2 = "cellId2"
    var users = [Users]()

     var filteredArray = [Users]()
//    var cont = [CNContact]()
    var mix : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Contacts"
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        setupToolBar()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId1)
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId2)
        fetchUser()
        tableView.delegate = self
        ////////////////////////////////////
        
        
        ////////////////////////////////////
    }
    func setupToolBar(){
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let button3 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action:#selector(navigateToSettings))
        let button2 = UIBarButtonItem(title: "Chats", style: .plain, target: self, action:#selector(navigateToChat))
        let button1 =  UIBarButtonItem(title: "Contacts", style: .plain, target: self, action: nil)
        items = [button1,space,button2,space,button3]
        self.toolbarItems = items
    }
    
    @objc func navigateToChat(){
        let messageVC = MessageController()
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    @objc func navigateToSettings(){
        let settingVC = SettingsViewController()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc func fetchUser(){
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictonary = snapshot.value as? [String: AnyObject]{
                let user = Users()
//                let mix = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictonary)
           
                let contactStore = CNContactStore()
                var contacts = [CNContact]()
                let keys = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey
                    ] as [Any]
                let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
                
                request.sortOrder = CNContactSortOrder.givenName
                
                
                do {
                    try contactStore.enumerateContacts(with: request){
                        (contact, stop) in
                        // Array containing all unified contacts from everywhere
//                        contacts.append(contact)
                        for phoneNumber in contact.phoneNumbers {
                            let number = (contact.phoneNumbers[0].value).value(forKey: "digits")as! String
                            let label = phoneNumber.label
                            if (user.phoneNumber == number){
                                self.users.append(user)
//                                self.mix.append(user)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                }
                            } else {
                            
                            
                            }
                            
                            self.mix.append(contact)
                  
                        }
              
                    }
                } catch {
                    print("unable to fetch contacts")
                }
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header"
        label.backgroundColor = UIColor(hexString: "#e1e1d0")
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        } else {
            return mix.count
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId1, for: indexPath) as! UserCell
            let user = users[indexPath.row]
            
            cell.textLabel?.text = user.userName
            let uid = Auth.auth().currentUser?.uid
//                   cell.detailTextLabel?.text = user.online
//                        if (user.online as? Bool)!{
//                            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 12)
//                            cell.detailTextLabel?.textColor = UIColor.flatGreen()
//                            cell.detailTextLabel?.text = "online"
//                        } else {
//                            let date = user.last_online!
//                            let seconds = user.last_online??.doubleValue
//                            let timeStamp = NSDate(timeIntervalSince1970: seconds!)
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "E, d MMM yy hh:mm:a"
//                            cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 12)
//                            cell.detailTextLabel?.textColor = UIColor.lightGray
//                            cell.detailTextLabel?.text = ("Last Seen: \(dateFormatter.string(from: timeStamp as Date))")
//
//
//
                        if let profileImageUrl = user.profileImageUrl {
                            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
                        }
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! ContactCell
            let user = mix[indexPath.row]
            let number = (user.phoneNumbers[0].value).value(forKey: "digits")as! String
            
           
            
            cell.textLabel?.text = user.givenName + " " + user.familyName
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
//            cell.backgroundColor = UIColor.lightGray
            return cell
        }
    }
       
   
    func pushToChatLog(user: Users){
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.user = user
            navigationController?.pushViewController(chatLogController, animated: true)
    }
    func pushToInvite(){
        let inviteController = InviteToSuupViewController()
        navigationController?.pushViewController(inviteController, animated: true)
    }

    var messagesController: MessageController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("Dismiss completed")
            let user1 = self.users[indexPath.row]
            self.pushToChatLog(user: user1)
        } else {
            self.pushToInvite()
        }
       
        
    }    
}

