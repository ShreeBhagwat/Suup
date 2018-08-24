//
//  ChatMessageCell.swift
//  Suup
//
//  Created by Gauri Bhagwat on 19/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
import AVFoundation
import AVKit
class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController: ChatLogController?
    
    var message: Message?{
        didSet{
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm: a"
                messageTimeStamp.text = dateFormatter.string(from: timeStampDate as Date)
            }
        }
    }
    
    lazy var playVideoButton : UIButton = {
       let button = UIButton(type: .system)
        let image = UIImage(named: "play1")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleVideoPlay), for: .touchUpInside)
        return button
    }()
    lazy var downloadAudioButton : UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "download"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(downloadAudioWith), for: .touchUpInside)
        return button
    }()
    
    lazy var playRecordedButton : UIButton = {
        let recordButton = UIButton(type: .system)
        let image = UIImage(named: "play1")
        recordButton.isUserInteractionEnabled = true
        recordButton.setImage(image, for: .normal)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(recordButton)
        recordButton.addTarget(self, action: #selector(handleAudioPLay1), for: .touchUpInside)
        return recordButton
    }()
    let audioSlider : UISlider = {
        let audioSlider = UISlider(frame:CGRect(x: 0, y: 0, width: 300, height: 20))
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 100
        audioSlider.isContinuous = true
        
        
        return audioSlider
    }()
    
    let avPlayerViewController = AVPlayerViewController()
    var playerLayer: AVPlayerLayer?
    var player:AVPlayer?
  
    
    @objc func handleVideoPlay() {
        if let videoUrl = message?.videoStorageUrl, let url = URL(string: videoUrl){
            player = AVPlayer(url: url)
            avPlayerViewController.player = player

            chatLogController?.present(avPlayerViewController, animated: true, completion: {
                self.avPlayerViewController.player?.play()
            })
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        }
}

    
    var audioPlayer : AVAudioPlayer!
    
 
    var localAudioUrl : String!
    @objc func downloadAudioWith(){
        print("download audio button pressed")
        let audioDownloadName = NSUUID().uuidString + "recievedAudio.m4a"
        let url = message?.audioUrl
        print(url)
        let ref = Storage.storage().reference(forURL: url!)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let downloadAudioUrl =  documentsDirectory.appendingPathComponent(audioDownloadName)
        let downloadTask = ref.write(toFile: downloadAudioUrl) { (url, error) in
            if error != nil {
                print(error)
            } else {
                self.localAudioUrl = (url?.absoluteString)!
                self.downloadAudioButton.isHidden = true
                self.playRecordedButton.isHidden = false
                self.audioSlider.isHidden = false
            }
        }
   
    }
    @objc func handleAudioPLay1() {
        
        print("Handel audio Play button pressed")
        if  let url = URL(string: localAudioUrl) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                 try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
                audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: "aac")
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print("Audio ready to play")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sample Text For Now"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        
        return tv
    }()
    
//    static let blueColour = UIColor.init(red: (110.0/255.0), green: (242.0/255.0), blue: (244.0/255.0), alpha: 1)
        static let blueColour = UIColor(hexString: "78daf6")
    
    let bubbleView: UIView = {
       let view = UIView()
        view.backgroundColor = blueColour
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

        view.isUserInteractionEnabled = true
       
        return view
    }()
    static let grayBubbleImage = UIImage(named: "bubble_gray")!.resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")!.resizableImage(withCapInsets: UIEdgeInsetsMake(30 ,36, 30, 36)).withRenderingMode(.alwaysTemplate)
    let bubbleImageView : UIImageView = {
      let imageView = UIImageView()
        imageView.image = ChatMessageCell.grayBubbleImage
        imageView.tintColor = UIColor(white: 0.96, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var messageImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageZoom))
        imageView.addGestureRecognizer(tapGesture)

        return imageView
    }()
        var messageTimeStamp: UILabel = {
        let messageTime = UILabel()
        messageTime.translatesAutoresizingMaskIntoConstraints = false
        messageTime.backgroundColor = UIColor.clear
        messageTime.font = UIFont.italicSystemFont(ofSize: 12)
        messageTime.layer.zPosition = 1
            messageTime.text = "00:00"
    
        return messageTime
    }()
    
    @objc func imageZoom(tapGesture:UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            self.chatLogController?.performZoomInImages(startingImageView: imageView)
        }
    }

    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleImageWidthAnchor: NSLayoutConstraint?
    var bubbleImageViewRightAnchor: NSLayoutConstraint?
    var bubbleImageViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        addSubview(messageTimeStamp)
        bubbleView.addSubview(bubbleImageView)
        
        
        //IOS 9 Constraints: x, y , width, height
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        //Play Button
        bubbleView.addSubview(playVideoButton)
        //IOS 9 Constraints: x, y , width, height
        playVideoButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playVideoButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playVideoButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playVideoButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(playRecordedButton)
        playRecordedButton.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        playRecordedButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playRecordedButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playRecordedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(downloadAudioButton)


        //IOS 9 Constraints: x, y , width, height


        downloadAudioButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        downloadAudioButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        downloadAudioButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        downloadAudioButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        
        //IOS 9 Constraints: x, y , width, height
//        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: messageTimeStamp.leftAnchor, constant: -10)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //BubbleImageView
        //Constraints:
//
//        bubbleImageViewRightAnchor = bubbleImageView.rightAnchor.constraint(equalTo: messageTimeStamp.leftAnchor, constant: -10)
//        bubbleImageViewRightAnchor?.isActive = true
//        bubbleViewLeftAnchor = bubbleImageView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
//        bubbleImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        bubbleImageWidthAnchor = bubbleImageView.widthAnchor.constraint(equalToConstant: 200)
//        bubbleImageWidthAnchor?.isActive = true
//        bubbleImageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
       
        bubbleImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
//        bubbleImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        bubbleImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        bubbleImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true

        //IOS 9 Constraints: x, y , width, height
//        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleImageView.leftAnchor, constant: 10).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleImageView.rightAnchor , constant: -10).isActive = true
//        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
        bubbleView.addSubview(audioSlider)
        audioSlider.leftAnchor.constraint(equalTo: playRecordedButton.rightAnchor, constant: 8 ).isActive = true
        audioSlider.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        audioSlider.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -10).isActive = true
        audioSlider.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        //MessageTimeStamp Constraints
//        messageTimeStamp.leftAnchor.constraint(equalTo: bubbleImageView.leftAnchor, constant: 20).isActive = true
        messageTimeStamp.bottomAnchor.constraint(equalTo: textView.bottomAnchor,constant: -10).isActive = true
        messageTimeStamp.rightAnchor.constraint(equalTo: bubbleImageView.rightAnchor,constant: -15).isActive = true
        messageTimeStamp.topAnchor.constraint(equalTo: textView.bottomAnchor)
        //            messageTimeStamp.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
