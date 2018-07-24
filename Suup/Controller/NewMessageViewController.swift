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
import SVProgressHUD

class NewMessageViewController: UITableViewController {
 

    let cellId = "cellId"
    var users = [Users]()
//    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationItem.title = "Chats"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }

    
    @objc func fetchUser(){
        SVProgressHUD.show()
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictonary = snapshot.value as? [String: AnyObject]{
                let user = Users()
                user.id = snapshot.key
             user.setValuesForKeys(dictonary)
//////////////////////////////////////////////
                let contactStore = CNContactStore()
                var contacts = [CNContact]()
                let keys = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey
                    ] as [Any]
                let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
                do {
                    try contactStore.enumerateContacts(with: request){
                        (contact, stop) in
                        // Array containing all unified contacts from everywhere
                        contacts.append(contact)
                        for phoneNumber in contact.phoneNumbers {
//                            let ph = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
//                             let number = phoneNumber.value as? CNPhoneNumber
                            let number = (contact.phoneNumbers[0].value).value(forKey: "digits")as! String
                            let label = phoneNumber.label
//                                let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                                //                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
//                                print("phone number",number.stringValue)
                                print("user phone",user.phoneNumber)
                                print(number)
                                print(contacts.count)
                                if (user.phoneNumber == number){
                        print("Similar Contact Found")
                        self.users.append(user)
                        DispatchQueue.main.async {
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                        }
                        } else {
                    print("Contacts Not Compared")
                    }
                }
//            }
        }
        } catch {
        print("unable to fetch contacts")
        }
    }
          
        }, withCancel: nil)
    }

    @objc func cancelButton(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count > 0 {
        return users.count
        }else {
            return 0
        }
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






//    private func fetchcontact2(){
//        let contactStore = CNContactStore()
//        var contacts = [CNContact]()
//        let keys = [
//            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
//            CNContactPhoneNumbersKey,
//            CNContactEmailAddressesKey
//            ] as [Any]
//        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
//        do {
//            try contactStore.enumerateContacts(with: request){
//                (contact, stop) in
//                // Array containing all unified contacts from everywhere
//                contacts.append(contact)
//                for phoneNumber in contact.phoneNumbers {
//                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
//                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
////                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
//                        print("phone number",number)
//                    }
//                }
//            }
//
//        } catch {
//            print("unable to fetch contacts")
//        }
//    }
////////////////
///////
//                let store = CNContactStore()
////                var con : [CNContact] = []
//                store.requestAccess(for: .contacts) { (granted, err) in
//                    if let err = err {
//                        print("Failed to request access:", err)
//                        return
//                    }
//                    if granted {
//                        print("Access granted")
//
//                        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
//                        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//
//                        do {
//
//                            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
//
//
//                                let ph = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
//                                self.contacts.append(Contact(givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: ph))
//                                print("user phone no",user.phoneNumber)
//
//
//
//                                if (user.phoneNumber == ph){
//                                    print("Similar Contact Found")
//                                    self.users.append(user)
//                                    DispatchQueue.main.async {
//                                        self.tableView.reloadData()
//                                        SVProgressHUD.dismiss()
//                                    }
//                                } else {
////                                    print("user ph no",user.phoneNumber)
////                                    print("phone ph no", ph)
//                                    print("Contacts Not Compared")
////                                    self.tableView.removeAll
//                                }
//
//
//                            })
//
//                        } catch let err {
//                            print("Failed to enumerate contacts:", err)
//                        }
//
//                    } else {
//                        print("Access denied..")
//                    }
//                }
///////////////////
//    private func fetchContacts() {
//        print("Attempting to fetch contacts today..")
//
//        let store = CNContactStore()
//
//        store.requestAccess(for: .contacts) { (granted, err) in
//            if let err = err {
//                print("Failed to request access:", err)
//                return
//            }
//            if granted {
//                print("Access granted")
//
//                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
//                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//
//                do {
//
//                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
//
//
//                        let ph = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
//                        self.contacts.append(Contact(givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: ph))
//                        print("fetch Contact method",self.contacts)
//
//                    })
//
//                } catch let err {
//                    print("Failed to enumerate contacts:", err)
//                }
//
//            } else {
//                print("Access denied..")
//            }
//        }
//    }
//

//

