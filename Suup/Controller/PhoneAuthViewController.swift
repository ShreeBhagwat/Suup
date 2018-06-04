//
//  WelcomeViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneAuthViewController: UIViewController {

    @IBOutlet weak var PhoneNumber: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func SendButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Phone Number", message: "Is this your Phone Number \(PhoneNumber.text!)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.PhoneNumber.text!, uiDelegate: nil) { (verificationID, error) in
                if error != nil {
                    print("error: \(String(describing: error?.localizedDescription))")
                    }else {
                    let defaults = UserDefaults.standard
                    defaults.setValue(verificationID, forKey: "authverificationID")
                    self.performSegue(withIdentifier: "goToVerification", sender: self)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
