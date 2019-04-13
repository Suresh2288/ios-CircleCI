//
//  HeaderMenuCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

class HeaderMenuCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile : UIImageView!{
        didSet{
            imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
            imgProfile.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var lblParentName : UILabel!
    @IBOutlet weak var lblVersionNumber: UILabel!
    
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
    
    // iPhone X Support
    @IBOutlet weak var lblVersionTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var headerBackgroundConstraint : NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showVersionNumber()
        
        if Device.size() == .screen5_8Inch{
            lblVersionTopConstraint.constant = -49
            headerBackgroundConstraint.constant = 180
        }else{
            lblVersionTopConstraint.constant = -19
            headerBackgroundConstraint.constant = 145
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showVersionNumber(){
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.lblVersionNumber.text = "V.\(version)"
        }
    }
    
}
