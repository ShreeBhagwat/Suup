//
//  NewMessageViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 12/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
import Contacts

class NewMessageViewController: UITableViewController {
 

    let cellId = "cellId"
    var users = [Users]()
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chats"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        self.fetchContacts()
        print(self.contacts)
        fetchUser()
    }

    
    func fetchUser(){
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
        
            if let dictonary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                let con = Contact()
                user.id = snapshot.key
             user.setValuesForKeys(dictonary)
                print(user.phoneNumber!,user.userName!,user.UserId!)
                  self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }


        }, withCancel: nil)
    }

    private func fetchContacts() {
        print("Attempting to fetch contacts today..")
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access:", err)
                return
            }
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
  
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        
                     
                        let ph = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                        self.contacts.append(Contact(givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: ph))
                        
                    })
                    
                } catch let err {
                    print("Failed to enumerate contacts:", err)
                }
                
            } else {
                print("Access denied..")
            }
        }
    }
    
    
    
    @objc func cancelButton(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = user.phoneNumber
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
        
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    var messagesController: MessageController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatLogController(user: user)
        }
    }
}

