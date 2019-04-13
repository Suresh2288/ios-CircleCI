//
//  MenuItemCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import BadgeSwift

class MenuItemCell: UITableViewCell {
    
    @IBOutlet weak var btnFirstItem : UIButton!
    @IBOutlet weak var lblFirstItem : UILabel!
    @IBOutlet weak var imgFirstItem: UIImageView!{
        didSet{
            imgFirstItem.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btnSecondItem : UIButton!
    @IBOutlet weak var lblSecondItem : UILabel!
    @IBOutlet weak var imgSecondItem: UIImageView!{
        didSet{
            imgSecondItem.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var lblBadge : BadgeSwift!{
        didSet{
            lblBadge.isHidden = true
        }
    }

    @IBOutlet weak var lblNotiBadge : BadgeSwift!{
        didSet{
            lblNotiBadge.isHidden = true
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
