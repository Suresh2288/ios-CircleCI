//
//  PromoCodeCell.swift
//  Plano
//
//  Created by Htarwara6245 on 5/31/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PromoCodeCell: UITableViewCell {
    
    @IBOutlet weak var lblPromoTitle : UILabel!{
        didSet{
            lblPromoTitle.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var lblPromoCode : UILabel!{
        didSet{
            lblPromoCode.numberOfLines = 0
            lblPromoCode.layer.cornerRadius = 5
            lblPromoCode.layer.masksToBounds = true
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
