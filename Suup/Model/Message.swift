//
//  Message.swift
//  Suup
//
//  Created by Gauri Bhagwat on 04/06/18.
//  Copyright © 2018 Development. All rights reserved.
//


class Message {
    
    var sender : String = ""
    var messageBody: String = ""
}



//override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
//    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
//}
//deinit {
//    NotificationCenter.default.removeObserver(self)
//}
//
//override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
//    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
//    
//    
//}
//
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    //TODO: TableView Delegate
//    
//    messageTableView.delegate = self
//    messageTableView.dataSource = self
//    
//    //TODO: TextField Delegate
//    messageTextField.delegate = self
//    
//    //TODO: Tapgesture
//    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
//    messageTableView.addGestureRecognizer(tapGesture)
//    
//    //TODO: Register Message XIB file
//    messageTableView.register(UINib(nibName:"CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
//    
//    configureTableView()
//    retrieveMessages()
//    messageTableView.separatorStyle = .none
//    
//    
//    
//    
//    
//}
//
//
//override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//}
//
//
//
//
////MARK:- Keyboard Methods
//@objc func keyboardWillAppear(notification: NSNotification?) {
//    guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
//        return
//    }
//    let keyboardHeight: CGFloat
//    if #available(iOS 11.0, *) {
//        keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
//        print("keyboardHeight\(keyboardHeight)")
//    } else {
//        keyboardHeight = keyboardFrame.cgRectValue.height
//    }
//    
//    self.heightConstraint.constant = 57 + keyboardHeight
//    print("Bottom View\(bottomView.constant)")
//    
//}
//
//@objc func keyboardWillDisappear(notification: NSNotification?) {
//    
//    self.heightConstraint.constant = 57
//    bottomView.constant = 57
//    print("bottomview closed\(bottomView.constant)")
//    self.view.layoutIfNeeded()
//    
//}
