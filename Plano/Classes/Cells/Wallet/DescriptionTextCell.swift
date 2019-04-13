//
//  DescriptionTextCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class DescriptionTextCell: UITableViewCell {
    
    @IBOutlet weak var lblDescripton : UILabel!{
        didSet{
            lblDescripton.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var lblDetail : UILabel!{
        didSet{
            lblDetail.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var btnSeeMore : UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
