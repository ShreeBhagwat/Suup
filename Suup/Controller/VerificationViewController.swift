//
//  RegisterViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseAuth
class VerificationViewController: UIViewController {

    @IBOutlet weak var VerificationCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func Verify(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        let credential = PhoneAuthProvider.provider().credential( withVerificationID: defaults.string(forKey: "authVID")!, verificationCode: VerificationCode.text!)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                print("error \(String(describing: error?.localizedDescription))")
            } else {
                print("Signed In")
                self.performSegue(withIdentifier: "goToLoggedin", sender: self)
            }
           
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
