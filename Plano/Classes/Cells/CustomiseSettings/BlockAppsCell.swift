//
//  BlockAppsCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class BlockAppsCell: UITableViewCell {
    
    @IBOutlet weak var lblAppTitle : UILabel!
    @IBOutlet weak var appNameView : UIView!{
        didSet{
            appNameView.layer.cornerRadius = 4.0
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
