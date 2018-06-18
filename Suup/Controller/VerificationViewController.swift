//
//  RegisterViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class VerificationViewController: UIViewController {

    @IBOutlet weak var VerificationCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func Verify(_ sender: Any) {
        SVProgressHUD.show()
        let defaults = UserDefaults.standard

        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authverificationID")!, verificationCode: VerificationCode.text!)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Invalid Verification Code", message: "The Verification Code does Not Match, Please Try Again", preferredStyle: .alert)

                let action = UIAlertAction(title: "Try Again", style: .default , handler: { (UIAlertAction) in
                    })
                 alert.addAction(action)
                self.present(alert, animated: true, completion: nil)

            }else {
                SVProgressHUD.dismiss()
               let userData = Auth.auth().currentUser?.phoneNumber
                print("\(String(describing: userData))")
                self.performSegue(withIdentifier: "goToLoggedin", sender: self)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }


}
