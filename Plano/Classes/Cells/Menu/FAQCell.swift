//
//  FAQCell.swift
//  Plano
//
//  Created by Thiha Aung on 7/9/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class FAQCell: UITableViewCell {
    
    @IBOutlet weak var lblQuestion : UILabel!{
        didSet{
            lblQuestion.numberOfLines = 0
        }
    }
    @IBOutlet weak var lblAnswer : UILabel!{
        didSet{
            lblAnswer.numberOfLines = 0
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
