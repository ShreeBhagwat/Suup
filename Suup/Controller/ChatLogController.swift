//
//  ChatLogController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 15/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit

class ChatLogController : UICollectionViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chat Log Controller"
        collectionView?.backgroundColor = UIColor.white
        
        setUpInputComponents()
    }
    func setUpInputComponents(){
        let containerView = UIView()
      
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // Constraints x,y,width,height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendbutton = UIButton(type: .system)
        sendbutton.setTitle("Send", for: .normal)
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sendbutton)
        // Constraints x,y,width,height
        sendbutton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendbutton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendbutton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendbutton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        
        let inputTextField = UITextField()
        inputTextField.placeholder = "Enter Message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextField)
        
        //Constraints x,y,width,height
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
    }
    
}
