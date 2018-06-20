//
//  ChatLogController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 15/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user: Users? {
        didSet{
            navigationItem.title = user?.userName
            oberveMessages()
        }
    }
    var messages = [Message]()
    
    func oberveMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {return}
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                // do we need to attempt filtering anymore
             self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
   lazy var inputTextFiled : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    let cellId = "cellId"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        

//        
//        setUpKeyboardObservers()
    }
    lazy var inputContainerView:UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "attachment")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(attachmentButton))
//        uploadImageView.addGestureRecognizer(tapGesture)
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(attachmentButton)))
        containerView.addSubview(uploadImageView)
        // Constraints x,y,width,height
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let sendbutton = UIButton(type: .system)
        sendbutton.setTitle("Send", for: .normal)
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
        sendbutton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
        containerView.addSubview(sendbutton)
        // Constraints x,y,width,height
        sendbutton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendbutton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendbutton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendbutton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        
        //        let inputTextField = UITextField()
        //        inputTextField.placeholder = "Enter Message..."
        //        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputTextFiled)
        
        //Constraints x,y,width,height
        inputTextFiled.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:8).isActive = true
        inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        //        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextFiled.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
        inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.gray
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        //Constraints X,Y,Width,Height
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        
         return containerView
    }()
    
    @objc func attachmentButton(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFromPicker = editedImage as? UIImage
        }else if let orignalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadImageToFirebaseStorage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImageToFirebaseStorage(image: UIImage){
        let imageName = NSUUID().uuidString
      let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(" Failed to upload Image", error)
                }
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Unable to upload image into storage due to \(err)")
                    }
                    
                let messageImageURL = url?.absoluteString
                    self.sendMessageWithImage(imageUrl: messageImageURL!, image: image)
                })
            })
        }
    }
    
    private func sendMessageWithImage(imageUrl : String, image: UIImage){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        
        let values = ["toId": toId,"fromId": fromId,"timeStamp":timeStamp,"imageUrl":imageUrl, "imageWidth":image.size.width, "imageHeight":image.size.height] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            self.inputTextFiled.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            let recipientUsersMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUsersMessageRef.updateChildValues([messageId: 1])
            
        }
    }
/////////////////////////////////////////////////////////////////////////////
//    guard self.profilePicture.image != nil else{return}
//    if let uploadData = UIImageJPEGRepresentation(self.profilePicture.image!, 0.1){
//
//        let StorageRef = Storage.storage().reference()
//        let StorageRefChild = StorageRef.child("user_profile_pictures/\(String(describing: uid)).jpg")
//        StorageRefChild.putData(uploadData, metadata: nil) { (metadata, err) in
//            if let err = err {
//                print("unable to upload Image into storage due to \(err)")
//            }
//            StorageRefChild.downloadURL(completion: { (url, err) in
//                if let err = err{
//                    print("Unable to retrieve URL due to error: \(err.localizedDescription)")
//                }
//                let profilePicUrl = url?.absoluteString
//                print("Profile Image successfully uploaded into storage with url: \(profilePicUrl ?? "" )")
//
//                let values = ["userName": self.NameText.text!,"phoneNumber":Auth.auth().currentUser?.phoneNumber,"userId":Auth.auth().currentUser?.uid,"profileImageUrl": profilePicUrl]
//
//                self.registerUserIntoDatabaseWithUid(uid: uid!, values: values as [String : AnyObject])
//            })
//        }
//
//    }
/////////////////////////////////////////////////////////////////////////////
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setUpKeyboardObservers(){
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
      
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification?) {
                guard let keyboardFrame = notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                    return
                }
                let keyboardHeight: CGFloat
                if #available(iOS 11.0, *) {
                    keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
                    print("keyboardHeight\(keyboardHeight)")
                } else {
                    keyboardHeight = keyboardFrame.cgRectValue.height
                }
        
                containerViewBottomAnchor?.constant = -keyboardHeight
                let keyboardSize = keyboardHeight
                let contentInsets: UIEdgeInsets
                if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
        
                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize, 0.0);
                }
                else {
                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize, 0.0);
        
                }
        let keyboardDuration = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
//                let indexPath = NSIndexPath(row: (messageArray.count-1), section: 0)
//                messageTableView.contentInset = contentInsets
//                messageTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
//                messageTableView.scrollIndicatorInsets = messageTableView.contentInset
            }
    
    @objc func keyboardWillDisappear(notification: NSNotification?) {
        let keyboardDuration = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
            self.containerViewBottomAnchor?.constant = 0
        }
            }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
      
        // Bubblw View Modification
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        return cell

    }
    
    private func setupCell(cell:ChatMessageCell, message: Message){
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            //Out Going Blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColour
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //Incoming Grey Message
            cell.bubbleView.backgroundColor = UIColor(red:240.0/255.0, green:240.0/255.0, blue:240.0/255.0, alpha:1.0)
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageFromCache(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }else {
            cell.messageImageView.isHidden = true
            
        }
    }
    
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
            case .portrait:
                print("Portrait")
            // Do something
            default:
                print("Anything But Portrait")
                // Do something else
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            print("rotation completed")
        })
        
        viewWillTransitionToSize(size: size, withTransitionCoordinator: coordinator)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text{
            height = estimatedFrameForText(text: text).height+20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            // h1/w1 = h2/w2
            //solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    private func estimatedFrameForText(text:String) -> (CGRect){
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string:text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    var containerViewBottomAnchor:NSLayoutConstraint?
    
  
    @objc func sendButtonPressed(){
       let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["text":inputTextFiled.text!,"toId": toId,"fromId": fromId,"timeStamp":timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            self.inputTextFiled.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            let recipientUsersMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUsersMessageRef.updateChildValues([messageId: 1])
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed()
        return true
    }
    
}

