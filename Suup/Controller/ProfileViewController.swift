//
//  ProfileViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 02/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import SVProgressHUD
import Firebase
import TransitionButton



class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var messageController : MessageController?
    var userArray :[User] = [User]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#76f7ee")
        view.addSubview(createProfileLabel)
        view.addSubview(profileNote)
        view.addSubview(profilePicture)
        view.addSubview(userName)
        view.addSubview(doneButton)
        
        setUpViewController()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfilePicture)))
        profilePicture.isUserInteractionEnabled = true
        
        
        // Do any additional setup after loading the view.
    }
   
    let createProfileLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Profile"
        label.backgroundColor = UIColor.init(red: (1), green: (1), blue: (1), alpha: 0.3)
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        
        return label
    }()
    
    let profileNote: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Enter below your Name and add a Profile Photo"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        
        
        return label
    }()
    
    lazy var profilePicture:UIImageView = {
        let profilePicture = UIImageView()
        profilePicture.image = UIImage(named: "profile")
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.contentMode = .scaleAspectFit

        profilePicture.clipsToBounds = true
        return profilePicture
    }()
    
    let userName : UITextField = {
        let textFiled = UITextField()
        textFiled.placeholder = "Enter Name"
        textFiled.layer.cornerRadius = 20
        textFiled.clipsToBounds = true
        textFiled.backgroundColor = UIColor.white
        textFiled.translatesAutoresizingMaskIntoConstraints = false
       return textFiled
    }()
    
    let doneButton : TransitionButton = {
        let button = TransitionButton(type: .custom)
        button.backgroundColor = UIColor.flatSkyBlue()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(DoneButtonPressed), for: .touchUpInside)
        
        return button
    }()

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func DoneButtonPressed() {
        let uid = Auth.auth().currentUser?.uid
        
        guard self.profilePicture.image != nil else{return}
        if let uploadData = UIImageJPEGRepresentation(self.profilePicture.image!, 0.1){
        
            let StorageRef = Storage.storage().reference()
            let StorageRefChild = StorageRef.child("user_profile_pictures/\(String(describing: uid)).jpg")
            StorageRefChild.putData(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("unable to upload Image into storage due to \(err)")
                }
                StorageRefChild.downloadURL(completion: { (url, err) in
                    if let err = err{
                        print("Unable to retrieve URL due to error: \(err.localizedDescription)")
                    }
                    let profilePicUrl = url?.absoluteString
                    print("Profile Image successfully uploaded into storage with url: \(profilePicUrl ?? "" )")
                    let values = ["userName": self.userName.text!,"phoneNumber":Auth.auth().currentUser?.phoneNumber,"userId":Auth.auth().currentUser?.uid,"profileImageUrl": profilePicUrl]
                    
                    self.registerUserIntoDatabaseWithUid(uid: uid!, values: values as [String : AnyObject])
                   
                })
            }
            
        }
   
            }
    private func registerUserIntoDatabaseWithUid(uid: String, values:[String: AnyObject]){
        let usersDB = Database.database().reference().child("Users").child(uid)
        let userDiconary = ["userId":Auth.auth().currentUser?.uid ?? String.self,
                            "userName": userName.text!,
                            "phoneNumber":Auth.auth().currentUser?.phoneNumber! ?? String.self] as [String : Any]
        
       
        usersDB.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, userDB) in
            if err != nil {
                print(err as Any)
                return
            }
            
            
            let user = Users()
            user.setValuesForKeys(values)
            self.messageController?.navBarWithUser(user: user)
            let secondVC = MessageController()
            self.navigationController?.pushViewController(secondVC, animated: true)
        })
    }
    
    @objc func addProfilePicture(){
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
  @objc  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFromPicker = editedImage as? UIImage
        }else if let orignalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profilePicture.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled")
        dismiss(animated: true, completion: nil)
    }
    
    func setUpViewController(){
        createProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createProfileLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        createProfileLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        createProfileLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        profileNote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileNote.topAnchor.constraint(equalTo: createProfileLabel.bottomAnchor, constant: 20).isActive = true
        profileNote.widthAnchor.constraint(equalToConstant: 300).isActive = true
        profileNote.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        profilePicture.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        profilePicture.topAnchor.constraint(equalTo: profileNote.bottomAnchor, constant: 20).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 80).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        userName.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor).isActive = true
        userName.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 10).isActive = true
        userName.widthAnchor.constraint(equalToConstant: 200).isActive = true
        userName.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true


    }
}
