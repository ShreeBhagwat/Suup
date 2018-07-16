//
//  StartViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                print("\(String(describing: user?.phoneNumber))")
                self.performSegue(withIdentifier: "goToMessageDirectly", sender: nil)
            }
        }
    }
    
    
    @IBAction func StartButtonPressed(_ sender: UIButton) {
    print("Please put Number for verification")
//       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

