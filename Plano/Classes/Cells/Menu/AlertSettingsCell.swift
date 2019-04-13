//
//  AlertSettingsCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/13/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import JTMaterialSwitch

class AlertSettingsCell: UITableViewCell {
    
    @IBOutlet weak var lblSettingTitle : UILabel!
    @IBOutlet weak var lblSettingDescription : UILabel!
    @IBOutlet weak var materialSwitch : MaterialSwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
