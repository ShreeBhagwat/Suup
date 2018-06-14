//
//  NewMessageViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 12/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UITableViewController {

    let cellId = "cellId"
    var users = [Users]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    
    func fetchUser(){
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
           
            if let dictonary = snapshot.value as? [String: AnyObject]{
                let user = Users()
             user.setValuesForKeys(dictonary)
//                print(user.phoneNumber!,user.userName!,user.UserId!)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
           
        }, withCancel: nil)
    }
    
    @objc func cancelButton(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = user.phoneNumber
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageFromCache(urlString: profileImageUrl)
        
//            let url = NSURL(string: profileImageUrl)
//            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
//                if error != nil {
//                    print(error)
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.profileImageView.image = UIImage(data: data!)
////                    cell.imageView?.image = UIImage(data: data!)
//                }
//
//            }.resume()
//        }
        
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

class UserCell : UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: ((textLabel?.frame.origin.y)!-2), width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 64, y: ((detailTextLabel?.frame.origin.y)!+2), width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        
        addSubview(profileImageView)
      
        //Left Anchor
        profileImageView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 8)

        //Center Anchor
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        //Width Anchor
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true

        // Height Anchor
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

