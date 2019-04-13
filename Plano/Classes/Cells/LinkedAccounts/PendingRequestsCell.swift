//
//  PendingRequestsCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PendingRequestsCell: UITableViewCell {
    
    @IBOutlet weak var lblName : UILabel!{
        didSet{
            lblName.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var imgProfile : UIImageView!{
        didSet{
            imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
            imgProfile.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var btnCancel : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
