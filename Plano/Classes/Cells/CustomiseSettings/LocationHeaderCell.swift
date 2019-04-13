//
//  LocationHeaderCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class LocationHeaderCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var locationBoundariesSwitch : MaterialSwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
