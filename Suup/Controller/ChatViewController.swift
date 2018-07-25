//
//  ChatTableViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//
//
//import UIKit
//import Firebase
//import FirebaseAuth
//import SVProgressHUD
//
//class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UITextViewDelegate {}

//    var messageArray : [Message] = [Message]()
//
//
//    ////////////////////////////////////////////////////
//
//    //MARK:- IBoutlests
//    @IBOutlet weak var bottomView: NSLayoutConstraint!
//    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
//
//    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var messageTextField: UITextField!
//    @IBOutlet weak var messageTableView: UITableView!
//    var heightAtIndexPath = NSMutableDictionary()
//
//
//    ////////////////////////////////////////////////////
//    //MARK:- TableView Did Appear and Disappear methods
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
//
//}
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
//        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
//
//    }
//
//    ////////////////////////////////////////////////////
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //TODO: TableView Delegate
//        textDidChange()
//
//        messageTableView.delegate = self
//        messageTableView.dataSource = self
//
//        //TODO: TextField Delegate
//        messageTextField.delegate = self
//
//        //TODO: Tapgesture
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
//        messageTableView.addGestureRecognizer(tapGesture)
//
//        //TODO: Register Message XIB file
//        messageTableView.register(UINib(nibName:"CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
//
//        configureTableView()
//        retrieveMessages()
//        messageTableView.separatorStyle = .none
//
//        messageTableView.rowHeight = UITableViewAutomaticDimension
//
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//
//    ////////////////////////////////////////////////////
//    //MARK:- Keyboard Methods
//    @objc func keyboardWillAppear(notification: NSNotification?) {
//        guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
//            return
//        }
//        let keyboardHeight: CGFloat
//        if #available(iOS 11.0, *) {
//            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
//            print("keyboardHeight\(keyboardHeight)")
//        } else {
//            keyboardHeight = keyboardFrame.cgRectValue.height
//        }
//
//        self.heightConstraint.constant = 57 + keyboardHeight
//        let keyboardSize = keyboardHeight
//        let contentInsets: UIEdgeInsets
//        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
//
//            contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize, 0.0);
//        }
//        else {
//            contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize, 0.0);
//
//        }
//        let indexPath = NSIndexPath(row: (messageArray.count-1), section: 0)
//        messageTableView.contentInset = contentInsets
//        messageTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
//        messageTableView.scrollIndicatorInsets = messageTableView.contentInset
//    }
//
//
//    @objc func keyboardWillDisappear(notification: NSNotification?) {
//
//        messageTableView.contentInset = UIEdgeInsets.zero
//        messageTableView.scrollIndicatorInsets = UIEdgeInsets.zero
//        self.heightConstraint.constant = 57
//        bottomView.constant = 57
//
//    }
//
//
//    ////////////////////////////////////////
//    //MARK:-tableViewDataSource
//    //TODO: cellForRowAtIndexPath
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
//
//        cell.messageBody.text! = messageArray[indexPath.row].messageBody
//        cell.senderUsername.text! = messageArray[indexPath.row].sender
//        cell.profilePicture.image = UIImage(named: "profile")
//
//        return cell
//    }
//
//    //TODO: numberOfRowsInSection
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return messageArray.count
//    }
//
//    //TODO: Declare Tableviwe Tapped here
//
//    @objc func tableViewTapped(){
//        messageTextField.endEditing(true)
//    }
//
//    //TODO: Declare configureTableview  here
//
//    func configureTableView(){
//        messageTableView.rowHeight = UITableViewAutomaticDimension
//        messageTableView.estimatedRowHeight = 120.0
//    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
//            return CGFloat(height.floatValue)
//        } else {
//            return UITableViewAutomaticDimension
//        }
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let height = NSNumber(value: Float(cell.frame.size.height))
//        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
//    }
//
//    func textDidChange(){
//        messageTableView.reloadData()
//        self.messageTableView.layoutIfNeeded()
//        self.messageTableView.setContentOffset(CGPoint.zero, animated: true)
//    }
//    /////////////////////////////////////////
//
//    //MARK:- TextField Delegate Methods
//
//
//
//    //////////////////////////////////////////
//    //MARK:- sendButtonPressed
//
//
//    @IBAction func sendButttonPressed(_ sender: Any) {
//        messageTextField.endEditing(true)
//
//        messageTextField.isEnabled = false
//        sendButton.isEnabled = false
//
//    // Message Database
//
//        let messageDB = Database.database().reference().child("Messages")
//        let messageDiconary = ["Sender":Auth.auth().currentUser?.phoneNumber,
//                               "MessageBody": messageTextField.text!]
//
//        messageDB.childByAutoId().setValue(messageDiconary){
//            (error, reference) in
//            if error != nil {
//                print(error!)
//            } else {
//                print("Message Saved Successfully!")
//                self.messageTextField.isEnabled = true
//                self.sendButton.isEnabled = true
//                self.messageTextField.text = ""
//            }
//        }
//
//
//    }
//
//    //TODO: create the retrieveMessages method here
//
//    func retrieveMessages(){
//        SVProgressHUD.show()
//        let messageDB = Database.database().reference().child("Messages")
//        messageDB.observe(.childAdded) { (snapshot) in
//            let snapshotValue = snapshot.value as! Dictionary<String,String>
//
//            let text = snapshotValue["MessageBody"]!
//            let sender = snapshotValue["Sender"]!
//
//            let message = Message()
//            message.messageBody = text
//            message.sender = sender
//
//            self.messageArray.append(message)
//            self.configureTableView()
//
//            self.messageTableView.reloadData()
//            let indexPath = NSIndexPath(row: (self.messageArray.count-1), section: 0)
//            self.messageTableView?.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
//            SVProgressHUD.dismiss()
//        }
//    }
//
//
//    /////////////////////////////////////////
//
//    //MARK:- Log Out Method
//    @IBAction func logoutButton(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//
//            navigationController?.popToRootViewController(animated: true)
//
//        }
//        catch {
//            print("error: there was a problem logging out")
//        }
//
//    }
//
//
//}
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


