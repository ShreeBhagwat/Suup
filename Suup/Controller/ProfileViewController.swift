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


class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var messageController : MessageController?
    var userArray :[User] = [User]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfilePicture)))
        profilePicture.isUserInteractionEnabled = true
        
        
        // Do any additional setup after loading the view.
    }
   

    @IBOutlet weak var NameText: UITextField!
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhoto(_ sender: Any) {
    }
    @IBOutlet weak var profilePicture: UIImageView!
    
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
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
                    
                    let values = ["userName": self.NameText.text!,"phoneNumber":Auth.auth().currentUser?.phoneNumber,"userId":Auth.auth().currentUser?.uid,"profileImageUrl": profilePicUrl]
                    
                    self.registerUserIntoDatabaseWithUid(uid: uid!, values: values as [String : AnyObject])
                })
            }
            
            
//            imageRef.putData(uploadData, metadata: nil) { (metadata, error) in
//                if error != nil{
//                    print(error)
//                    return
//                }else {
//                    let downloadUrl = metadata.downloadUrl()
//                    let values = ["userName": self.NameText.text!,"phoneNumber":Auth.auth().currentUser?.phoneNumber,"userId":Auth.auth().currentUser?.uid,"profileImageUrl": metadata.downloadUrl()]
//                    self.registerUserIntoDatabaseWithUid(uid: uid, values: <#T##[String : AnyObject]#>)
//                }
//            }
        }
      
        
        
               
            }
    private func registerUserIntoDatabaseWithUid(uid: String, values:[String: AnyObject]){
        let usersDB = Database.database().reference().child("Users").child(uid)
        let userDiconary = ["userId":Auth.auth().currentUser?.uid ?? String.self,
                            "userName": NameText.text!,
                            "phoneNumber":Auth.auth().currentUser?.phoneNumber! ?? String.self] as [String : Any]
        
       
        usersDB.updateChildValues(values as Any as! [AnyHashable : Any], withCompletionBlock: { (err, userDB) in
            if err != nil {
                print(err as Any)
                return
            }
//            self.messageController?.fetchUser()
//            self.messageController?.navigationItem.title = values["userName"] as? String
            let user = Users()
            user.setValuesForKeys(values)
            self.messageController?.navBarWithUser(user: user)
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

    
   
}
