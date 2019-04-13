//
//  PremiumSecondCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/13/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

class PremiumSecondCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var imgFreePack : UIImageView!
    @IBOutlet weak var imgLitePack : UIImageView!
    @IBOutlet weak var imgFamilyPack : UIImageView!
    @IBOutlet weak var imgAnnualPack : UIImageView!
    @IBOutlet weak var titleLeadingConstrait : NSLayoutConstraint!

    @IBOutlet weak var lblInfo : UILabel!
    override func awakeFromNib() {
        
        if Device.size() <= .screen7_9Inch{
            titleLeadingConstrait.constant = 20
        }
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
