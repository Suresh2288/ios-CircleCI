//
//  ScheduleCell.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    
    @IBOutlet weak var lblScheduleTitle : UILabel!
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var lblScheduleDay : UILabel!
    @IBOutlet weak var lblScheduleTime : UILabel!
    @IBOutlet weak var scheduleTypeSwitch : MaterialSwitch!{
        didSet{
            scheduleTypeSwitch.thumbOnTintColor = UIColor.white
            scheduleTypeSwitch.trackOnTintColor = Color.Magenta.instance()
            scheduleTypeSwitch.rippleFillColor = Color.Magenta.instance()
        }
    }
    @IBOutlet weak var scheduleNameView : UIView!{
        didSet{
            scheduleNameView.layer.cornerRadius = 4.0
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
