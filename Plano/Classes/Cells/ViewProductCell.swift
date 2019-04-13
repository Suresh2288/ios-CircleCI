//
//  ViewProductCell.swift
//  Plano
//
//  Created by John Raja on 22/06/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class ViewProductCell: UITableViewCell {

    @IBOutlet weak var lbl_ViewProduct_Outlet: UILabel!
    @IBOutlet weak var vw_BaseView_Outlet: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
