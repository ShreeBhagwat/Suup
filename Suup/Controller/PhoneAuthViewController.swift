//
//  WelcomeViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 24/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import ChameleonFramework
import CTKFlagPhoneNumber
import TransitionButton



class PhoneAuthViewController: UIViewController, UITextFieldDelegate, CountryPickerDelegate {
 
    
  

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexString: "#71f2da")
        view.addSubview(enterPhoneNumberLabel)
        view.addSubview(phoneNumbeNote)
        view.addSubview(enterPhoneNumberText)
        view.addSubview(sendButton)
        setUpPhoneAuthViewController()

        // Do any additional setup after loading the view.
    }
    

    let enterPhoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Phone Number"
        label.backgroundColor = UIColor.init(red: (1), green: (1), blue: (1), alpha: 0.3)
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        
        
        return label
    }()
    
    let phoneNumbeNote : UILabel = {
       let label = UILabel()
        label.numberOfLines = 3
        label.text = "Suup will send a SMS to Verify your phone number. Please enter your phone number with country code"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        
        
        return label
    }()
    
    let enterPhoneNumberText : CTKFlagPhoneNumberTextField = {
       let textFiled = CTKFlagPhoneNumberTextField()
        textFiled.placeholder = "Enter Phone Number"
        textFiled.layer.cornerRadius = 20
        textFiled.clipsToBounds = true
        textFiled.backgroundColor = UIColor.white
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.keyboardType = UIKeyboardType.numberPad
        textFiled.font  = UIFont.systemFont(ofSize: 18.0)
        return textFiled
    }()
    
    let sendButton : TransitionButton = {
        let button = TransitionButton(type: .custom)
        button.backgroundColor = UIColor.flatSkyBlue()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send OTP", for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(SendButtonPressed), for: .touchUpInside)
        
        return button
    }()

    @objc func SendButtonPressed() {
        print("Send Button Pressed")
        let cc = enterPhoneNumberText.getCountryPhoneCode()
        print(cc)
        let ph = enterPhoneNumberText.text
        print(ph)
        let phoneNumber = cc! + ph!
        let ppp = phoneNumber.replacingOccurrences(of: "-", with: "")
        let ppp1 = ppp.replacingOccurrences(of: " ", with: "")
        print(ppp1)
        let alert = UIAlertController(title: "Phone Number", message: "Is this your Phone Number \(phoneNumber)", preferredStyle: .alert)

        let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            self.sendButton.startAnimation()
            let qualityOfServiceClass = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
            backgroundQueue.async {
                sleep(1)
                DispatchQueue.main.async(execute: {
                    PhoneAuthProvider.provider().verifyPhoneNumber(ppp, uiDelegate: nil) { (verificationID, error) in
                        print("phone number for verification\(ppp)")
                        if error != nil {
                            print("error: \(String(describing: error?.localizedDescription))")
                        }else {
                            let defaults = UserDefaults.standard
                            defaults.set(verificationID, forKey: "authVerificationID")
                           
                        }
                    }
                      self.sendButton.stopAnimation(animationStyle: .expand, completion: {
                        let secondVC = VerificationViewController()
                        self.present(secondVC, animated: true, completion: nil)
            })
            })
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
    
    func setUpPhoneAuthViewController(){
        
        enterPhoneNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enterPhoneNumberLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        enterPhoneNumberLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        enterPhoneNumberLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        ////////////////////////////////////////////////////////////////
        
        phoneNumbeNote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        phoneNumbeNote.topAnchor.constraint(equalTo: enterPhoneNumberLabel.bottomAnchor, constant: 20).isActive = true
        phoneNumbeNote.widthAnchor.constraint(equalToConstant: 300).isActive = true
        phoneNumbeNote.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //////////////////////////////////////////////////////////////////
        enterPhoneNumberText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        enterPhoneNumberText.topAnchor.constraint(equalTo: phoneNumbeNote.bottomAnchor, constant: 10).isActive = true
        enterPhoneNumberText.widthAnchor.constraint(equalToConstant: 300).isActive = true
        enterPhoneNumberText.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //////////////////////////////////////////////////////////////////
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    var cc : String?
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //todo
    }
    
}
