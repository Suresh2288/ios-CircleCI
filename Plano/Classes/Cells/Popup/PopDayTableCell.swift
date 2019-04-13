//
//  PopDayTableCell.swift
//  PopupViewPlano
//
//  Created by Toe Wai Aung on 5/4/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopDayTableCell: UITableViewCell {

    @IBOutlet weak var lbl_day: UILabel!
    @IBOutlet weak var checkbox: VKCheckbox!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        checkbox.checkboxValueChangedBlock = {
            isOn in
            print("Basic checkbox is \(isOn ? "ON" : "OFF")")
        }
        
    }

}
