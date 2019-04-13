//
//  ScheduleFooterCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ScheduleFooterCell: UITableViewCell {
    
    @IBOutlet weak var lblTitleInfo : UILabel!
    @IBOutlet weak var lblTimeInfo : UILabel!
    @IBOutlet weak var lblDayInfo : UILabel!
    @IBOutlet weak var btnAddSchedule : UIButton!
    @IBOutlet weak var addScheduleView : UIView!{
        didSet{
            addScheduleView.layer.borderColor = Color.Cyan.instance().cgColor
            addScheduleView.layer.borderWidth = 0.5
            addScheduleView.layer.cornerRadius = 4.0
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
