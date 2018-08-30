//
//  LoginViewController.swift
//  Suup
//
//  Created by Gauri Bhagwat on 31/05/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit
import TransitionButton
class LoginViewController: UIViewController , UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#76f7ee")
        view.addSubview(Label)
        view.addSubview(createProfile)
        setupViewController()
        
    }
    
    let Label: UILabel = {
        let label = UILabel()
        label.text = "Verification Successful !"
        label.backgroundColor = UIColor.init(red: (1), green: (1), blue: (1), alpha: 0.3)
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20.0)
        
        return label
    }()
    
    let createProfile : TransitionButton = {
        let button = TransitionButton(type: .custom)
        button.backgroundColor = UIColor.flatSkyBlue()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create Profile!", for: .normal)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(createProfileButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    func  setupViewController(){
        Label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        Label.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        Label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        Label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        createProfile.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createProfile.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300).isActive = true
        createProfile.widthAnchor.constraint(equalToConstant: 200).isActive = true
        createProfile.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    @objc func createProfileButtonPressed(){
        let secondVC = ProfileViewController()
        self.navigationController?.pushViewController(secondVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
