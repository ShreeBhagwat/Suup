//
//  StartViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit

import Firebase
import ChameleonFramework
import TransitionButton

class StartViewController: UIViewController, UINavigationControllerDelegate{
    let startButton = TransitionButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.backgroundColor = UIColor.flatSkyBlue()
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitle("Start Messaging", for: .normal)
        startButton.cornerRadius = 20
        startButton.spinnerColor = UIColor.white
        self.view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(startMessaging), for: .touchUpInside)
        
        // Constaints for button
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
   
    
    @objc func startMessaging(){
//        startButton.startAnimation()
//        let qualityOfServiceClass = DispatchQoS.QoSClass.background
//        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
//        backgroundQueue.async {
//            sleep(2)
//            DispatchQueue.main.async(execute: {
//                self.startButton.stopAnimation(animationStyle: .expand, completion: {
                    let secondVC = PhoneAuthViewController()
                    self.navigationController?.pushViewController(secondVC, animated: true)
              
//            })
//        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                print("\(String(describing: user?.phoneNumber))")
               let uid = Auth.auth().currentUser?.uid
                UsersPresence().checkUserStatus(userid: uid!)
                self.performSegue(withIdentifier: "goToMessageDirectly", sender: nil)
                
            }
        }
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

