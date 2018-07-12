//
//  ChatLogController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 15/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import ChameleonFramework
import MobileCoreServices
import AVFoundation
import ContactsUI


class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
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
                messagesRef.keepSynced(true)
                userMessageRef.keepSynced(true)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextFiled : UITextField = {
        let textField = UITextField()
        
        
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        textField.layer.borderWidth = CGFloat(Float(1.0))
        textField.layer.cornerRadius = 14
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(11, 0, 11)
        
        return textField
    }()
   
    
   lazy var inputTextView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.yellow
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .headline)
//        textView.isScrollEnabled = false
        textView.delegate = self
//        textViewDidChange(textView)


        return textView
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
//        collectionView?.autoresizingMask = [.flexibleHeight]
        
        
        //
        setUpKeyboardObservers()
 
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let startinglength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startinglength + lengthToAdd - lengthToReplace
        if newLength == 0 {
            print("textFiled Empty")
            self.recordAudioButton.setImage(#imageLiteral(resourceName: "ic_voice"), for: .normal)
           self.recordAudioButton.addTarget(self, action: #selector(self.recordAudioButtonPressed), for: .touchUpInside)
           self.recordAudioButton.isEnabled = true
            self.recordAudioButton.isHidden = false
            self.sendbutton.isEnabled = false
            self.sendbutton.isHidden = true
        } else {
            print("textfiled")
            UIView.transition(with: sendbutton, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.sendbutton.setImage(#imageLiteral(resourceName: "sendf"), for: .normal)
                self.sendbutton.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
                self.recordAudioButton.isEnabled = false
                self.recordAudioButton.isHidden = true
                self.sendbutton.isEnabled = true
                self.sendbutton.isHidden = false
            }, completion: nil)
        }
        return true
    }

    let sendbutton = UIButton(type: .custom)
    let recordAudioButton = UIButton(type: .custom)
    
    lazy var inputContainerView:UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:50)
        containerView.backgroundColor = UIColor(hexString: "#fbfbfb")
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "attachment")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(attachmentButton)))
        containerView.addSubview(uploadImageView)
        // Constraints x,y,width,height
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        containerView.addSubview(inputTextFiled)
      
        if inputTextFiled.text?.isEmpty ?? true {
            print("TextFiled is Empty")
            UIView.transition(with: recordAudioButton, duration: 0.5, options: .transitionFlipFromRight, animations: {
                self.recordAudioButton.setImage(#imageLiteral(resourceName: "ic_voice"), for: .normal)
                }, completion: nil)
        } else {
            print("textfiled is not empty")
            UIView.animate(withDuration: 0.1, animations: {
                self.sendbutton.setImage(#imageLiteral(resourceName: "sendf"), for: .normal)
            }, completion: nil)
        }
        sendbutton.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(sendbutton)
        
            // Constraints x,y,width,height
            sendbutton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            sendbutton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            sendbutton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            sendbutton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        recordAudioButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(recordAudioButton)
        // Constraints x,y,width,height
        recordAudioButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        recordAudioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        recordAudioButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        recordAudioButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextFiled)
        
        //Constraints x,y,width,height

        inputTextFiled.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:8).isActive = true
        inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextFiled.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -50).isActive = true
        inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor,constant: -15).isActive = true
        
        
//        containerView.addSubview(inputTextView)
//
//        inputTextView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:8).isActive = true
//        inputTextView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextView.rightAnchor.constraint(equalTo: sendbutton.leftAnchor).isActive = true
//        //        inputTextView.heightAnchor.constraint(equalTo: containerView.heightAnchor,constant: -15).isActive = true
//        inputTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
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
    
    @objc func recordAudioButtonPressed(){
        print("recordAudioButtonPressed")
    }
    //Attachment Button
    @objc func attachmentButton(){
        let alert = UIAlertController(title: "Media", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photos And Videos", style: .default, handler: { _ in
            self.openPhotos()
        }))
        alert.addAction(UIAlertAction(title: "Documents", style: .default, handler: { _ in
            self.sendDocuments()
        }))
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            self.sendLocation()
        }))
        alert.addAction(UIAlertAction(title: "Contact", style: .default, handler: { _ in
            self.sendContact()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func sendDocuments(){
        print("send Documents pressed")
    }
    func sendContact(){
        print("send Contact Pressed")
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        cnPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        self.present(cnPicker,animated: true,completion: nil)
    }
    func sendLocation(){
        print("Send Location Pressed")
    }
    func openCamera(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        imagePickerController.allowsEditing = true
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    func openPhotos(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage,kUTTypeMovie] as [String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    func contactPickerFunc(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        let name = CNContactFormatter.string(from: contact, style: .fullName)
        for number in contact.phoneNumbers {
            let mobile = number.value.value(forKey: "digits") as? String
            if (mobile?.count)! > 7 {
                print(number)
            }
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // We Selected Video
            handelVideoSelectedForUrl(url:videoUrl)
            
        } else {
            
            // We Selected Image
            handelImageSelectedForInfo(info: info as [String : AnyObject])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handelVideoSelectedForUrl(url: NSURL){
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference()
        let uid = Auth.auth().currentUser?.uid
        let videoStorgareRef = storageRef.child("message_Video/\(String(describing: uid))").child(filename)
        let uploadTask = videoStorgareRef.putFile(from: url as URL, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Failed to upload Video",error)
            }
            videoStorgareRef.downloadURL(completion: { (url, err) in
                if err != nil {
                    print("Failed To Upload Video",err)
                }
                if let videoStorageUrl = url?.absoluteString {
                }
            })
        }
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.userName
        }
    }
    
    private func handelImageSelectedForInfo(info:[String: AnyObject]){
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFromPicker = editedImage as? UIImage
        }else if let orignalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadImageToFirebaseStorage(image: selectedImage)
        }
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
                    let Url = url
                    let messageImageURL = url?.absoluteString
                    self.sendMessageWithImage(imageUrl: messageImageURL!, image: image)
//                    self.downlaodImage(url: Url!,image: image)

                })
            })
        }
    }
    
//    func downloadImage(url: URL, completion: ((UIImage) -> ())? = nil) {
//
//        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//
//            guard let httpURLResponse = response as? HTTPURLResponse,
//                error == nil, httpURLResponse.statusCode == 200 else {
//                    print(error?.localizedDescription ?? "Error status code \((response as? HTTPURLResponse)?.statusCode)")
//                    return
//            }
//
//            guard let data = data, let image = UIImage(data: data) else {
//                print("No image data found")
//                return
//            }
//
//            completion?(image)
//            print("Image Downloded ")
//        }).resume()
//    }
//
    func downlaodImage(url: URL, image: UIImage){
        let downloadref = Storage.storage().reference(withPath: "message_images")
        let localRef = URL(string: "file/private/var/mobile/Containers/Data/")!
        
        let downlaodTask = downloadref.write(toFile: localRef) { (url, error) in
            if error != nil {
                print("error",error)
            }
            else {
                let messageimageUrl = url?.absoluteString
                self.sendMessageWithImage(imageUrl: messageimageUrl!, image: image)
            }
        }
    }
    
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setUpKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func keyboardWillShow(){
        if  messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
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
        
        cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        let seconds = message.timeStamp?.doubleValue
        let timeStamp = NSDate(timeIntervalSince1970: seconds!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:a"
        cell.messageTimeStamp.text = dateFormatter.string(from: timeStamp as Date)       
     
        setupCell(cell: cell, message: message)
        
        // Bubblw View Modification
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 40 + cell.messageTimeStamp.frame.width
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        return cell
    }
    
    private func setupCell(cell:ChatMessageCell, message: Message){
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            //Out Going Blue
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.bubbleImageView.image = ChatMessageCell.blueBubbleImage
            cell.bubbleImageView.tintColor = ChatMessageCell.blueColour
            cell.messageTimeStamp.textColor = UIColor.flatBlue()
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false

            
        } else {
            
            //Incoming Grey Message
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.bubbleImageView.image = ChatMessageCell.grayBubbleImage
            cell.bubbleImageView.tintColor = UIColor(red:240.0/255.0, green:240.0/255.0, blue:240.0/255.0, alpha:1.0)
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.messageTimeStamp.textColor = UIColor.lightGray
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageFromCache(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.bubbleImageView.tintColor = UIColor.clear
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
        print("Send Button pressed")
        let properties = ["text":inputTextFiled.text!] as [String : Any]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
        inputTextFiled.endEditing(true)
    }
    
    private func sendMessageWithImage(imageUrl : String, image: UIImage){
        
        let properties:[String:AnyObject] = (["imageUrl":imageUrl, "imageWidth":image.size.width, "imageHeight":image.size.height] as? [String:AnyObject])!
        
        sendMessageWithProperties(properties:properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        
        var values = ["toId": toId,"fromId": fromId,"timeStamp":timeStamp] as [String : Any]
        
        //Append Properties dictionary onto Values
        // Key = $0 Value = $1
        properties.forEach({values[$0] = $1})
        
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
    var startingFrame : CGRect?
    var zoomingImageView:UIImageView?
    var blackBackgroundView: UIView?
    var backButton:UIButton?
    var startingImageView: UIImageView?
    var shareButton: UIButton?
    
    
    // Image Zooming Logic
    func performZoomInImages(startingImageView : UIImageView){
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        textFieldShouldEndEditing(inputTextFiled)
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        print(startingFrame)
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        self.zoomingImageView?.backgroundColor = UIColor.red
        self.zoomingImageView?.image = startingImageView.image

        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            
            backButton = UIButton(type: .custom)
            backButton?.setTitle("Back", for: .normal)
            backButton?.setTitleColor(UIColor.white, for: .normal)
            backButton?.setImage(#imageLiteral(resourceName: "back1"), for: .normal)
            backButton?.translatesAutoresizingMaskIntoConstraints = false
            backButton?.addTarget(self, action: #selector(imageBackButtonPressed), for: .touchUpInside)
            
            shareButton = UIButton(type: .custom)
            shareButton?.setImage(#imageLiteral(resourceName: "share_ic"), for: .normal)
            shareButton?.translatesAutoresizingMaskIntoConstraints = false
            shareButton?.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)

            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView!)
            keyWindow.addSubview(backButton!)
            keyWindow.addSubview(shareButton!)
 
            //share Button Constraints
            shareButton?.leftAnchor.constraint(equalTo: (blackBackgroundView?.leftAnchor)!).isActive = true
            shareButton?.bottomAnchor.constraint(equalTo: (blackBackgroundView?.bottomAnchor)!, constant: -10).isActive = true
            shareButton?.widthAnchor.constraint(equalToConstant: 80).isActive = true
            shareButton?.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            
            //Back Button Constraints
            backButton?.leftAnchor.constraint(equalTo: (blackBackgroundView?.leftAnchor)!, constant: 10).isActive = true
            backButton?.topAnchor.constraint(equalTo: (blackBackgroundView?.topAnchor)!, constant: 10).isActive = true
            backButton?.widthAnchor.constraint(equalToConstant: 80).isActive = true
            backButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            UIView.animate(withDuration: 0.5, delay: 0,usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                self.backButton?.isHidden = false
                self.backButton?.isEnabled = true
                self.shareButton?.isHidden = false
                self.shareButton?.isEnabled = true
                //Maths
                //h2 / w1 = h1/w1
                //h2 = h1/w1*w1
                
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                //                self.zoomingImageView?.backgroundColor = UIColor.black
                //                self.zoomingImageView?.frame = UIScreen.main.bounds
                //                self.zoomingImageView?.contentMode = .scaleAspectFit
                
                self.zoomingImageView?.center = keyWindow.center
            }, completion: nil)
            
        }
    }
    
    @objc func imageBackButtonPressed(){
        
        if let zoomOutImageView = zoomingImageView{
            // Animate back to controller
            keyboardWillShow()
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            self.backButton?.isEnabled = false
            self.backButton?.isHidden = true
            self.shareButton?.isEnabled = false
            self.shareButton?.isHidden = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                self.startingImageView?.isHidden = false
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
            }
        }
    }
    @objc func shareButtonPressed(){
        imageBackButtonPressed()
        let image = UIImage()
        let imageToShare = [image]
        var activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities:  nil)
        
        activityViewController.popoverPresentationController?.sourceView?.addSubview(startingImageView!)
        self.present(activityViewController, animated: true, completion: nil)
        
    }
  
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
         sendbutton.setImage(#imageLiteral(resourceName: "ic_voice"), for: .normal)
        textField.resignFirstResponder()
     
        return true
    }
   
}
extension ChatLogController : UITextViewDelegate {
////
//    func textViewDidChange(_ textView: UITextView) {
////        if textView.contentSize.height > textView.frame.size.height {
////
////            let fixedWidth = textView.frame.size.width
////            textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
////
////            var newFrame = textView.frame
////            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
////
////
////            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
////
////            textView.frame = newFrame;
////
////
////
////        }
////    }
//
//
//    print("text view did change\n")
//    let textViewFixedWidth: CGFloat = textView.frame.size.width
//    let newSize = textView.sizeThatFits(CGSize(width: textViewFixedWidth, height: CGFloat.greatestFiniteMagnitude))
//    var newFrame: CGRect = textView.frame
//    //
//    var textViewYPosition = textView.frame.origin.y
//    var heightDifference = textView.frame.height - newSize.height
//    //
//    if (abs(heightDifference) > 5) {
//    newFrame.size = CGSize(width: max(newSize.width, textViewFixedWidth), height: newSize.height)
//    newFrame.offsetBy(dx: 0.0, dy: heightDifference)
//    //
////    updateParentView(heightDifference: heightDifference)
//    }
//    textView.frame = newFrame
//}
//    func updateParentView(heightDifference: CGFloat) {
////        //
////        var newContainerViewFrame: CGRect = inputContainerView.frame
////        //
////        let containerViewHeight = inputContainerView.frame.size.height
////        print("container view height: \(containerViewHeight)\n")
////        //
////        let newContainerViewHeight = containerViewHeight + heightDifference
////        print("new container view height: \(newContainerViewHeight)\n")
////        //
////        let containerViewHeightDifference = containerViewHeight - newContainerViewHeight
////        print("container view height difference: \(containerViewHeightDifference)\n")
////        //
//////        newContainerViewFrame.size = CGSizeMake(inputContainerView.frame.size.width, newContainerViewHeight)
////        newContainerViewFrame.size = CGSize(width: inputContainerView.frame.size.width, height: newContainerViewHeight)
////        //
//////        newContainerViewFrame.origin.y - containerViewHeightDifference
////        //
////        inputContainerView.frame = newContainerViewFrame
//
//
//            //
//            var newContainerViewFrame: CGRect = inputContainerView.frame
//            //
//            var containerViewHeight = inputContainerView.frame.size.height
//            print("container view height: \(containerViewHeight)\n")
//            //
//            var newContainerViewHeight = containerViewHeight + heightDifference
//            print("new container view height: \(newContainerViewHeight)\n")
//            //
//            var containerViewHeightDifference = containerViewHeight - newContainerViewHeight
//            print("container view height difference: \(containerViewHeightDifference)\n")
//            //
//        newContainerViewFrame.size = CGSize(width: inputContainerView.frame.size.width, height: newContainerViewHeight)
////         newContainerViewFrame.origin.y - containerViewHeightDifference
//            //
//            newContainerViewFrame.offsetBy(dx: 0.0, dy: containerViewHeightDifference)
//            //
//             inputContainerView.frame = newContainerViewFrame
//
//    }
}
