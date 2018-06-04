//
//  CustomMessageCell.swift
//  Suup
//
//  Created by Gauri Bhagwat on 03/06/18.
//  Copyright © 2018 Development. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    
    @IBOutlet weak var messageBackground: UIView!
    
  
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var senderUsername: UILabel!
    
    
    @IBOutlet weak var messageBody: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
