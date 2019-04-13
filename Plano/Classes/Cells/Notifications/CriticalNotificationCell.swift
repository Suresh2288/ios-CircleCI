//
//  CriticalNotificationCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class CriticalNotificationCell: UITableViewCell {
    
    @IBOutlet weak var imgNotification : UIImageView!{
        didSet{
            imgNotification.clipsToBounds = true
        }
    }
    @IBOutlet weak var lblTitle : UILabel!{
        didSet{
            lblTitle.numberOfLines = 0
        }
    }
    @IBOutlet weak var lblDescription : UILabel!{
        didSet{
            lblDescription.numberOfLines = 0
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
