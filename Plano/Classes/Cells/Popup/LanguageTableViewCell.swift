//
//  LanguageTableViewCell.swift
//  Plano
//
//  Created by Toe Wai Aung on 7/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLanguage: UILabel!
    
    @IBOutlet weak var iconlagRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
