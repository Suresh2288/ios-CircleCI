//
//  LocationCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var lblLocationTitle : UILabel!
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var locationTypeSwitch : MaterialSwitch!{
        didSet{
            locationTypeSwitch.thumbOnTintColor = UIColor.white
            locationTypeSwitch.trackOnTintColor = Color.Magenta.instance()
            locationTypeSwitch.rippleFillColor = Color.Magenta.instance()
        }
    }
    @IBOutlet weak var locationNameView : UIView!{
        didSet{
            locationNameView.layer.cornerRadius = 4.0
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
