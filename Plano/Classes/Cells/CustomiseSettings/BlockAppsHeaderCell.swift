//
//  BlockAppsHeaderCell.swift
//  Plano
//
//  Created by Htarwara6245 on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class BlockAppsHeaderCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var blockAppsSwitch : MaterialSwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
