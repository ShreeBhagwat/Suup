//
//  SettingsViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 28/08/18.
//  Copyright © 2018 Development. All rights reserved.
//

import Foundation
import Firebase
import Contacts
import SVProgressHUD

class SettingsViewController : UITableViewController,UINavigationControllerDelegate {
    var items = [UIBarButtonItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
    
        setupToolBar()
    }
    func setupToolBar(){
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let button3 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: nil)
        let button2 = UIBarButtonItem(title: "Chats", style: .plain, target: self, action:#selector(navigateToChat) )
        let button1 =  UIBarButtonItem(title: "Contacts", style: .plain, target: self, action: #selector(navigateToContacts))
        items = [button1,space,button2,space,button3]
        self.toolbarItems = items
    }
    
    @objc func navigateToChat(){
        let messageVC = MessageController()
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    @objc func navigateToContacts(){
        let contactVC = ContactsViewController()
        self.navigationController?.pushViewController(contactVC, animated: true)
    }
}
