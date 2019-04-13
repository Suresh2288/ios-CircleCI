//
//  SubscribeButtonCell.swift
//  Plano
//
//  Created by John Raja on 17/12/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class SubscribeButtonCell: UITableViewCell {
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var btnTopSpaceConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnSubscribe.layer.cornerRadius = btnSubscribe.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
