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
import ChameleonFramework
import CTKFlagPhoneNumber
import TransitionButton
import KWVerificationCodeView

class VerificationViewController: UIViewController {

    var otpView = KWVerificationCodeView(frame: CGRect(x: 100, y: 300, width: 200, height: 60))

    @IBOutlet weak var VerificationCode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otpView.digits = 6
        otpView.textSize = 21.0
        otpView.textColor = UIColor.black
//        view.backgroundColor = UIColor(hexString: "#71f2da")
        view.backgroundColor = UIColor(hexString: "#76f7ee")
        view.addSubview(verificationTitle)
        view.addSubview(verificationNote)
//        view.addSubview(verificationTextField)
        view.addSubview(otpView)
        view.addSubview(verificationButton)
        
          setupVerificationViewController()

        // Do any additional setup after loading the view.
    }
    
    let verificationTitle: UILabel = {
        let label = UILabel()
        label.text = "OTP Verification"
        label.backgroundColor = UIColor.init(red: (1), green: (1), blue: (1), alpha: 0.3)
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        
        return label
    }()
    
    let verificationNote: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.text = "We have sent a 6 digit Verification Code via SMS. Check your phone and enter the code below"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        
        
        return label
    }()
    
    
    let verificationButton : TransitionButton = {
        let button = TransitionButton(type: .custom)
        button.backgroundColor = UIColor.flatSkyBlue()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send OTP", for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(Verify), for: .touchUpInside)
        
        return button
    }()
    
    
    @objc func Verify() {
        let otp:String = ("\(otpView.getVerificationCode())")
        print(otp)
        let defaults = UserDefaults.standard
        let credential: PhoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: defaults.string(forKey: "authVerificationID")!, verificationCode: otp)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                let alert = UIAlertController(title: "Invalid Verification Code", message: "\(error)The Verification Code does Not Match, Please Try Again", preferredStyle: .alert)

                let action = UIAlertAction(title: "Try Again", style: .default , handler: { (UIAlertAction) in
                    })
                 alert.addAction(action)
                self.present(alert, animated: true, completion: nil)

            }else {
               let userData = Auth.auth().currentUser?.phoneNumber
                print("\(String(describing: userData))")
                let secondVC = LoginViewController()
                self.present(secondVC, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    func setupVerificationViewController(){
        verificationTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        verificationTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        verificationTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        verificationTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        ////////////////////////////////////////////////////////////////
        
        verificationNote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        verificationNote.topAnchor.constraint(equalTo: verificationTitle.bottomAnchor, constant: 20).isActive = true
        verificationNote.widthAnchor.constraint(equalToConstant: 300).isActive = true
        verificationNote.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //////////////////////////////////////////////////////////////////

        verificationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        verificationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300).isActive = true
        verificationButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        verificationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
  
    }


}
