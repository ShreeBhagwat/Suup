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

class NewMessageViewController: UITableViewController , UISearchResultsUpdating{
 

    let cellId = "cellId"
    var users = [Users]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredArray = [Users]()

//    lazy var searchBar = UISearchBar(frame: CGRect.zero)

    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Users"
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func searchBarEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArray = users.filter({ user -> Bool in
          return  (user.userName?.lowercased().contains(searchText.lowercased()))!
        })
        self.tableView.reloadData()
    }
    func isFiltering()->Bool{
        return searchController.isActive && !searchBarEmpty()
    }
    
    @objc func fetchUser(){
        SVProgressHUD.show()
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictonary = snapshot.value as? [String: AnyObject]{
                let user = Users()
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
                do {
                    try contactStore.enumerateContacts(with: request){
                        (contact, stop) in
                        // Array containing all unified contacts from everywhere
                        contacts.append(contact)
                        for phoneNumber in contact.phoneNumbers {
                            let number = (contact.phoneNumbers[0].value).value(forKey: "digits")as! String
                            let label = phoneNumber.label
                                if (user.phoneNumber == number){
                        self.users.append(user)
                        DispatchQueue.main.async {
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                        }
                        } else {
                    }
                }
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
        if isFiltering(){
            return filteredArray.count
        }else {
            if users.count > 0 {
                return users.count
            }else {
                return 0
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user: Users
        if isFiltering(){
        user = filteredArray[indexPath.row]
        } else {
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.userName
        let uid = Auth.auth().currentUser?.uid
//       cell.detailTextLabel?.text = user.online
            if (user.online as? Bool)!{
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 12)
                cell.detailTextLabel?.textColor = UIColor.flatGreen()
                cell.detailTextLabel?.text = "online"
            } else {
                let date = user.last_online!
                let seconds = user.last_online?.doubleValue
                let timeStamp = NSDate(timeIntervalSince1970: seconds!)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM yy hh:mm:a"
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 12)
                cell.detailTextLabel?.textColor = UIColor.lightGray
                cell.detailTextLabel?.text = ("Last Seen: \(dateFormatter.string(from: timeStamp as Date))")
            
            }
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
            }
            
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    var messagesController: MessageController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user: Users
            if self.isFiltering(){
                user = self.filteredArray[indexPath.row]

            } else {
                let user1 = self.users[indexPath.row]
          
            self.messagesController?.showChatLogController(user: user1)
        }
    }
    }
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
}

