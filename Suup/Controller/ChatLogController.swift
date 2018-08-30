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
import Alamofire


class ChatLogController : UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate {
   
    
    var user: Users? {
        didSet{
            navigationItem.title = user?.userName
            
//            self.navigationItem.titleView = setTitle(title: (user?.userName)!, subtitle: subtitleViewText())
       
            oberveMessages()
        }
    }
    func setTitle(title:String, subtitle:String) -> UIView {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    func subtitleViewText() -> String {

        let subtitleViewText = UILabel()

        if user?.online == false {
            let date = user?.last_online!
            let seconds = user?.last_online?.doubleValue
            let timeStamp = NSDate(timeIntervalSince1970: seconds!)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:a"
            subtitleViewText.text = ("Last Seen: \(dateFormatter.string(from: timeStamp as Date))")
            return subtitleViewText.text!
        } else {
            subtitleViewText.text = "online"
            return subtitleViewText.text!
        }
    }
    
    var audioRecord = AudioRecord()
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
//                messagesRef.keepSynced(true)
//                userMessageRef.keepSynced(true)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: "suupwall")?.draw(in: self.view.bounds)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.backgroundColor = UIColor.init(patternImage: image!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "chatlog")!)
        
        
       startAudioSession()
       setupRecorder()
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        setUpKeyboardObservers()
        
        audioSlider.isHidden = true
        audioPlayTime.isHidden = true
        audioPlayButton.isHidden = true
        slideToCancel.isHidden = true
        deleteAudioButton.isHidden = true
        upButton.isHidden = true
        collectionView?.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        timeLable.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        removeNotificationObservers()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let startinglength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length
        let newLength = startinglength + lengthToAdd - lengthToReplace
        if newLength == 0 {
            
            self.recordAudioButton.tintColor = UIColor.white
            self.recordAudioButton.setImage(#imageLiteral(resourceName: "ic_voice"), for: .normal)
            self.recordAudioButton.addTarget(self, action: #selector(recordAudioButtonPressed), for: .touchDown)
            self.recordAudioButton.addTarget(self, action: #selector(recordAudioButtonNotPressed), for: .touchUpInside)
           self.recordAudioButton.isEnabled = true
            self.recordAudioButton.isHidden = false
            self.sendbutton.isEnabled = false
            self.sendbutton.isHidden = true
        } else {
            
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
    let timeLable: UITextView = {
        let timeLable = UITextView()
        timeLable.backgroundColor = UIColor.clear
        timeLable.textAlignment = .center
        timeLable.layer.cornerRadius = 10
        timeLable.text = "00:00:00"
        timeLable.font = UIFont.systemFont(ofSize: 16)
        timeLable.translatesAutoresizingMaskIntoConstraints = false
        timeLable.isEditable = false
        timeLable.textColor = UIColor.red
        
        return timeLable
    }()
    
    let audioPlayTime: UITextView = {
        let timeLable = UITextView()
        timeLable.backgroundColor = UIColor.clear
        timeLable.textAlignment = .center
        timeLable.layer.cornerRadius = 10
        timeLable.text = "00:00:00"
        timeLable.font = UIFont.systemFont(ofSize: 16)
        timeLable.translatesAutoresizingMaskIntoConstraints = false
        timeLable.isEditable = false
        timeLable.textColor = UIColor.red
        
        return timeLable
    }()
    let slideToCancel : UITextView = {
        let slideToCancel = UITextView()
        slideToCancel.backgroundColor = UIColor.clear
        slideToCancel.textAlignment = .center
        slideToCancel.layer.cornerRadius = 10
        slideToCancel.text = "<<< Slide To Cancel <<< "
        slideToCancel.font = UIFont.systemFont(ofSize: 17)
        slideToCancel.translatesAutoresizingMaskIntoConstraints = false
        slideToCancel.isEditable = false
        slideToCancel.textColor = UIColor.black
        return slideToCancel
    }()
    
    let audioSlider : UISlider = {
        let audioSlider = UISlider(frame:CGRect(x: 0, y: 0, width: 300, height: 20))
         audioSlider.translatesAutoresizingMaskIntoConstraints = false
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.addTarget(self, action: #selector(changeAudioSliderValue), for: .valueChanged)
        audioSlider.isContinuous = true
        
        
        return audioSlider
    }()
    
    lazy var audioPlayButton : UIButton = {
        let audioPlayButton = UIButton(type: .custom)
        audioPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        audioPlayButton.tintColor = UIColor.blue
        audioPlayButton.isSelected = false
        audioPlayButton.addTarget(self, action: #selector(toggelPlaybutton), for: .touchUpInside)
        audioPlayButton.translatesAutoresizingMaskIntoConstraints = false
        
        return audioPlayButton
    }()
    
    let deleteAudioButton : UIButton = {
       let deleteAudioButton = UIButton(type: .custom)
        deleteAudioButton.setImage(#imageLiteral(resourceName: "delet"), for: .normal)
        deleteAudioButton.translatesAutoresizingMaskIntoConstraints = false
        deleteAudioButton.addTarget(self, action: #selector(deleteAudioButtonPressed), for: .touchDown)
        return deleteAudioButton
    }()
    
    let upButton : UIButton = {
        let upButton = UIButton(type: .custom)
        upButton.setImage(#imageLiteral(resourceName: "up"), for: .normal)
        upButton.translatesAutoresizingMaskIntoConstraints = false
        upButton.addTarget(self, action: #selector(upButtonPressed), for: .touchDown)
        return upButton
    }()
    
    let sendbutton = UIButton(type: .custom)
    let recordAudioButton = UIButton(type: .custom)
    let uploadImageView = UIImageView()

    lazy var inputContainerView:UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height:50)
        containerView.backgroundColor = UIColor(hexString: "#fbfbfb").withAlphaComponent(0.7)
        
        
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
        recordAudioButton.layer.cornerRadius = 20
        recordAudioButton.layer.borderWidth = 1
        recordAudioButton.layer.borderColor = UIColor.black.cgColor
        // Constraints x,y,width,height
//        recordAudioButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        recordAudioButton.leftAnchor.constraint(equalTo: inputTextFiled.rightAnchor, constant: 4).isActive = true
        recordAudioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        recordAudioButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        recordAudioButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        recordAudioButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -10).isActive = true
        
        containerView.addSubview(timeLable)
        //Constraints of time lable
//        timeLable.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8).isActive = true
////        timeLable.centerYAnchor.constraint(equalTo: recordAudioButton.centerYAnchor).isActive = true
//        timeLable.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        timeLable.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -5).isActive = true
//        timeLable.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        timeLable.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        timeLable.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        timeLable.widthAnchor.constraint(equalToConstant: 80).isActive = true
        timeLable.heightAnchor.constraint(equalToConstant: 25).isActive = true
        

         containerView.addSubview(slideToCancel)
        slideToCancel.rightAnchor.constraint(equalTo: recordAudioButton.leftAnchor, constant: -10).isActive = true
        slideToCancel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        slideToCancel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        slideToCancel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        

        containerView.addSubview(inputTextFiled)
        //Constraints x,y,width,height

        inputTextFiled.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:8).isActive = true
        inputTextFiled.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextFiled.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -50).isActive = true
        inputTextFiled.heightAnchor.constraint(equalTo: containerView.heightAnchor,constant: -15).isActive = true
        
        containerView.addSubview(audioPlayButton)
        audioPlayButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        audioPlayButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        audioPlayButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        audioPlayButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        containerView.addSubview(deleteAudioButton)
        deleteAudioButton.leftAnchor.constraint(equalTo:audioPlayButton.rightAnchor, constant: 8).isActive = true
        deleteAudioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        deleteAudioButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        deleteAudioButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        containerView.addSubview(upButton)
        upButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        upButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        upButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        upButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(audioPlayTime)
        audioPlayTime.rightAnchor.constraint(equalTo: upButton.leftAnchor, constant: -8).isActive = true
        audioPlayTime.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        audioPlayTime.widthAnchor.constraint(equalToConstant: 80).isActive = true
        audioPlayTime.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        containerView.addSubview(audioSlider)
        audioSlider.leftAnchor.constraint(equalTo: deleteAudioButton.rightAnchor, constant: 8 ).isActive = true
        audioSlider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        audioSlider.rightAnchor.constraint(equalTo: audioPlayTime.leftAnchor, constant: -10).isActive = true
        audioSlider.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        
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
    @objc func toggelPlaybutton(sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            
            print(sender.isSelected)
            audioPlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
//            let url = getAudiFileURL()
            playRecordedAudio()
            
        }
            
        else {
            
            print(sender.isSelected)
            audioPlayButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            pauseRecordedAudio()
        }
    }
    @objc func recordAudioButtonPressed(){
        inputTextFiled.isHidden = true
        uploadImageView.isHidden = true
//        audioSlider.isHidden = false
//        audioPlayButton.isHidden = false
        slideToCancel.isHidden = false
      timeLable.isHidden = false
      startTimer()
      recordAudioButton.backgroundColor = UIColor.red
      AudioServicesPlayAlertSound(1110)
      startRecording()

    }
    @objc func recordAudioButtonNotPressed(){
        timeLable.isHidden = true
        resetTimer()
        recordAudioButton.backgroundColor = UIColor.clear
        AudioServicesPlayAlertSound(1111)
        audioSlider.isHidden = false
        audioPlayButton.isHidden = false
        slideToCancel.isHidden = true
        recordAudioButton.isHidden = true
        upButton.isHidden = false
        deleteAudioButton.isHidden = false
        audioPlayTime.isHidden = false
        finishRecording(success: true)
        
        
    }
    
    @objc func deleteAudioButtonPressed(){
        audioSlider.isHidden = true
        audioPlayButton.isHidden = true
        slideToCancel.isHidden = true
        upButton.isHidden = true
        audioPlayTime.isHidden = true
        deleteAudioButton.isHidden = true
        inputTextFiled.isHidden = false
        uploadImageView.isHidden = false
        recordAudioButton.isHidden = false
        
//        finishRecording(success: false)
        deleteAudioRecorded()
    }
    
    @objc func upButtonPressed(){
        audioSlider.isHidden = true
        audioPlayButton.isHidden = true
        slideToCancel.isHidden = true
        upButton.isHidden = true
        audioPlayTime.isHidden = true
        deleteAudioButton.isHidden = true
        inputTextFiled.isHidden = false
        uploadImageView.isHidden = false
        recordAudioButton.isHidden = false
//        finishRecording(success: true)
        let audioFileUrl = getAudiFileURL()
        handleAudioSendWith(url: audioFileUrl)
        
        
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
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
        imagePickerController.allowsEditing = true
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.modalPresentationStyle = .fullScreen
        
        
        present(imagePickerController, animated: true, completion: nil)
    }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//            picker.dismiss(animated: true, completion: nil)
            let name = CNContactFormatter.string(from: contact, style: .fullName)
            for number in contact.phoneNumbers {
                let mobile = number.value.value(forKey: "digits") as? String
                if (mobile?.count)! > 7 {
                    handelContactSend(contact: name!)
                }
                
            }
        }
    func openPhotos(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self

        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage,kUTTypeMovie] as [String]
        
        present(imagePickerController, animated: true, completion: nil)
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
        let filename = NSUUID().uuidString + ".mov"
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
                    if let thumbnailImage = self.thumbnailImageForVideoFileUrl(videoFileUrl: url!){
                        self.uploadImageToFirebaseStorage(image: thumbnailImage, completion: { (imageUrl) in
                            let properties:[String:AnyObject] = (["imageUrl":imageUrl,"imageWidth":thumbnailImage.size.width, "imageHeight":thumbnailImage.size.height,"videoStorageUrl" : videoStorageUrl] as? [String:AnyObject])!
                            self.sendMessageWithProperties(properties: properties)
                        })
                        
                    }
                    
                }
            })
        }
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
//                self.navigationItem.title = String(completedUnitCount)
                
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.userName
        }
    }
    
    private func thumbnailImageForVideoFileUrl(videoFileUrl: URL) -> UIImage?{
        let asset = AVAsset(url: videoFileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)

        } catch let err {
            print(err)
        }
        return nil
    }
    
    private func handelContactSend(contact : String){
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference()
        let uid = Auth.auth().currentUser?.uid
        let contactStorageRef = storageRef.child("contact_storage/\(String(describing: uid))").child(filename)
        
        if let uploadData:NSData = NSKeyedArchiver.archivedData(withRootObject: contact) as NSData {
            contactStorageRef.putData(uploadData as Data, metadata: nil) { (snapshot, error) in
                if error != nil {
                    print("Failed to put COntact data",error)
                }
                contactStorageRef.downloadURL(completion: { (url, err ) in
                    if  err != nil {
                        print("Contact failed to download url",error)
                    }
                    let contactUrl = url?.absoluteString
                })
            }
        }
    }
    
    @objc func handelImageSelectedForInfo(info:[String: AnyObject]){
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFromPicker = editedImage as? UIImage
        }else if let orignalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadImageToFirebaseStorage(image: selectedImage) { (messageImageUrl) in
                self.sendMessageWithImage(imageUrl: messageImageUrl, image: selectedImage)
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

    private func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString + ".jpg"
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
                    completion(messageImageURL!)

                })
        
            })
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
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillDisappear(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    func removeNotificationObservers() {
        print("Keyboard Notification Removed")
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(){
        print("Keyboard shown")
        if  messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
    }

    
    @objc func keyboardWillAppear(notification: NSNotification?) {
        if  messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        }
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
            
            collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: keyboardSize, right: 0)
        }
        else {
            collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
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
            self.collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        
        let seconds = message.timeStamp?.doubleValue
        let timeStamp = NSDate(timeIntervalSince1970: seconds!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:a"
        cell.messageTimeStamp.text = dateFormatter.string(from: timeStamp as Date)       
     
        setupCell(cell: cell, message: message)
        
        // Bubblw View Modification
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 100
            cell.textView.isHidden = false
            cell.audioSlider.isHidden = true
            cell.playRecordedButton.isHidden = true
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.audioSlider.isHidden = true
            cell.playRecordedButton.isHidden = true
        } else if message.audioUrl != nil {
            cell.audioSlider.isHidden = true
            cell.playRecordedButton.isHidden = true
            cell.textView.isHidden = true
            cell.bubbleWidthAnchor?.constant = 250
            cell.bubbleView.heightAnchor.constraint(equalToConstant: 70)
        } else if message.videoStorageUrl != nil {
            cell.audioSlider.isHidden = true
            cell.playRecordedButton.isHidden = true
        }
        
        cell.playVideoButton.isHidden = message.videoStorageUrl == nil
//        cell.playRecordedButton.isHidden = message.audioUrl == nil
//        cell.audioSlider.isHidden = message.audioUrl == nil
        cell.downloadAudioButton.isHidden = message.audioUrl == nil
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
        let DeviceId = AppDelegate.DeviceId
        let timeStamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        
        var values = ["toId": toId,"fromId": fromId,"timeStamp":timeStamp,"DeviceId":DeviceId] as [String : Any]
        
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
//            self.setupPushNotification(DeviceId: DeviceId)
        }
    }
    func setupPushNotification(DeviceId:String){
        guard let message = inputTextFiled.text else {return}
        let title = user?.userName
        let body = message
        let toDeviceId = DeviceId
        var header:HTTPHeaders = HTTPHeaders()
        
        header = ["content-type":"application/json","Authorization":"key=\(AppDelegate.ServerKey)"]
        let notification = ["to":"\(toDeviceId)","notification":["body":body,"title":title,"badge":1,"sound":"default"]] as [String : Any]
        
        Alamofire.request(AppDelegate.Notification_URL as URLConvertible, method: .post as HTTPMethod, parameters: notification, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            print(response)
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
        let image = startingImageView?.image
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
var audioRecorder : AVAudioRecorder!
var audioPlayer : AVAudioPlayer!
var recordingSession: AVAudioSession!
var settings   = [String : Any]()

var fileName = NSUUID().uuidString + ".m4a"
var toggleState = 1

var audioTimer = Timer()
var seconds = 0
var secondsFraction = 0
var timer = Timer()
var audioPlayTimer = Timer()
var audioPlayLabelTimer = Timer()
var audioMinutes = 0
var audioSeconds = 0
var isTimerRunning = false
var resumeTapped = false


extension ChatLogController : UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{

    func startAudioSession(){
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.setupRecorder()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func setupRecorder(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
        
        // Audio Settings
        

         settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getAudiFileURL() -> URL {
//        let fileName = NSUUID().uuidString + ".mp4"
//        let filename = "soundRec.mp4"
    
        return getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    func startRecording() {
        setupRecorder()

        do {
            
            let audioFileUrl = getAudiFileURL()
            print(audioFileUrl)
           try audioRecorder =  AVAudioRecorder(url: audioFileUrl, settings: settings)
            print(audioFileUrl)
            audioRecorder.delegate = self
            audioRecorder.record()

        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {

        if success {
            
            audioRecorder.stop()
            
//             let audioFileUrl = getAudiFileURL()
//            handleAudioSendWith(url: audioFileUrl)
        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }
    
    func playRecordedAudio(){
        let url = getAudiFileURL()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                            audioPlayLabelTimer.invalidate()
            
                            audioPlayer = try AVAudioPlayer(contentsOf: url)
                            audioPlayer.volume = 10.0
                            audioPlayer?.delegate = self
                            audioPlayer.stop()
                            audioSlider.maximumValue = Float(audioPlayer.duration)
                            audioPlayer.currentTime = TimeInterval(audioSlider.value)
                            audioPlayer?.prepareToPlay()
                            audioTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioSlider), userInfo: nil, repeats: true)
            
                            audioPlayer?.play()
                            audioPlayLabelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioTimer), userInfo: nil, repeats: true)
                            
            

            print("audio playing")
        } catch {
            print("not nhplayi")
        }
    }
    
    
    func pauseRecordedAudio(){
        audioPlayer.pause()
        updateAudioTimer()
        audioPlayLabelTimer.invalidate()
        
        
    }


    
    func deleteAudioRecorded(){
        let url = getAudiFileURL()
        do {
       try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
        
    }

    @objc func changeAudioSliderValue(){
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(audioSlider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @objc func updateAudioSlider(){
        audioSlider.value = Float(audioPlayer.currentTime)
    }
    
    @objc func updateAudioTimer() {
        print("update Audio Timer Playin")
        var currentTime = Int(audioPlayer.currentTime)
        var duration = Int(audioPlayer.duration)
        var total = currentTime - duration
        var totalString = String(total)
        var maxTimer = Float(audioPlayer.duration)
        
        audioMinutes = currentTime/60
        audioSeconds = currentTime - audioMinutes/60
        print("update Audio Timer\(currentTime,duration,total,totalString,audioMinutes,audioSeconds)")
        
        audioPlayTime.text = NSString(format: "%02d:%02d", audioMinutes,audioSeconds) as String
        if audioPlayer.currentTime == audioPlayer.duration {
            audioPlayLabelTimer.invalidate()
        }
    }
    
    func handleAudioSendWith(url: URL) {
        
//        guard let fileUrl = URL(string: url) else {
//            return
//        }
       
        print(url)
        let ref = Storage.storage().reference().child("message_voice").child(fileName)
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "error")
            }
            ref.downloadURL(completion: { (url, error) in
                if error != nil {
                    print("Error",error)
                }
                let downloadUrl = url?.absoluteString
                let values: [String : Any] = ["audioUrl": downloadUrl]
                self.sendMessageWithProperties(properties: values as [String : AnyObject])
            })
            }
        }
    
    
  

    
    ///////////////////////////////////////////////// TIMER
    

    
    //MARK: - IBActions
    
    func startTimer() {
        print("timer class")
        if isTimerRunning == false {
            runTimer()
            
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        print("time running")
        
    }
    
    
    func resetTimer() {
        timer.invalidate()
        secondsFraction = 0
        isTimerRunning = false
        
    }
    
    
    @objc func updateTimer() {
        secondsFraction += 1
     timeLable.text! = String(format: "%02d:%02d:%02d", (secondsFraction % 36000) / 6000, (secondsFraction % 6000) / 100, (secondsFraction % 3600) % 60 )
//        timeLable.text = timeString(time: TimeInterval(secondsFraction))
//        timeLable.text = String(secondsFraction)
        //            labelButton.setTitle(timeString(time: TimeInterval(seconds)), for: UIControlState.normal)
        
    }
    
//    func timeString(time:TimeInterval) -> String {
//        let hours = Int(time) / 3600
//        let minutes = Int(time) / 60 % 60
//        let seconds = Int(time) % 60
//        let secondsFraction = Int(time) / 100
////        let restTime = ((hours<10) ? "0" : "") + String(hours) + ":" + ((minutes<10) ? "0" : "") + String(minutes) + ":" + ((seconds<10) ? "0" : "") + String(seconds)
//        return String(format:"%02i:%02i:%02i", hours, minutes, seconds,secondsFraction)
////        return restTime
//    }
    
    }

