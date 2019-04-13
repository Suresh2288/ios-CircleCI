//
//  LocationFooterCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class LocationFooterCell: UITableViewCell {
    
    @IBOutlet weak var lblTitleInfo : UILabel!
    @IBOutlet weak var btnCreateNewArea : UIButton!
    @IBOutlet weak var addLocationView : UIView!{
        didSet{
            addLocationView.layer.borderColor = Color.Cyan.instance().cgColor
            addLocationView.layer.borderWidth = 0.5
            addLocationView.layer.cornerRadius = 4.0
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
