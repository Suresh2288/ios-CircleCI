//
//  ChildRewardsCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/17/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftDate

class ChildRewardsCell: UICollectionViewCell {
    
    @IBOutlet weak var imgItem : UIImageView!{
        didSet{
            imgItem.clipsToBounds = true
            imgItem.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var lblStatus : UILabel!{
        didSet{
            lblStatus.layer.borderColor = UIColor.lightGray.cgColor
            lblStatus.layer.borderWidth = 0.5
        }
    }
    
    @IBOutlet weak var lblExpired : UILabel!{
        didSet{
            let color = UIColor.black
            let blackTrans = UIColor.withAlphaComponent(color)(0.7)
            lblExpired.backgroundColor = blackTrans
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        // Initialization code
    }
    
    func setStatusLabel(date : Date,expireDate : Date) -> String{
        var remove7DaysComponents = DateComponents()
        remove7DaysComponents.day = -7
        let sevenDaysAgo = Calendar.current.date(byAdding: remove7DaysComponents, to: expireDate)
        if date < sevenDaysAgo!{
            lblStatus.isHidden = false
            lblExpired.isHidden = true
            return ""
        }else if date >= sevenDaysAgo! && date < expireDate{
            lblStatus.isHidden = false
            lblExpired.isHidden = true
            return " Expiring soon "
        }else if date >= expireDate{
            lblStatus.isHidden = true
            lblExpired.isHidden = false
            return ""
        }
        return ""
    }
}
