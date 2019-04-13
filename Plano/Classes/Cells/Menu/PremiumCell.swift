//
//  PremiumCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/13/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

class PremiumCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblFreePack : UILabel!
    @IBOutlet weak var lblLitePack : UILabel!
    @IBOutlet weak var lblFamilyPack : UILabel!
    @IBOutlet weak var lblAnnualPack : UILabel!

    @IBOutlet weak var lblAnnualPackTitle: UILabel!
    @IBOutlet weak var lblFamilyPackTitle: UILabel!
    @IBOutlet weak var lblFreePackTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
