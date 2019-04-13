//
//  ShopItemCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/10/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftDate

class ShopItemCell: UICollectionViewCell {
    
    
    @IBOutlet weak var lblPoints : UILabel!{
        didSet{
            lblPoints.numberOfLines = 0
        }
    }

    @IBOutlet weak var lblItemTitle: UILabel! {
        didSet {
            lblItemTitle.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var lblItemDescription: UILabel! {
        didSet {
            lblItemDescription.numberOfLines = 3
        }
    }
    
    @IBOutlet weak var imgItem : UIImageView!{
        didSet{
            imgItem.clipsToBounds = true
            imgItem.contentMode = .scaleAspectFit
            imgItem.layer.borderColor = UIColor.lightGray.cgColor
            imgItem.layer.borderWidth = 0.5
        }
    }
    
    @IBOutlet weak var lblStatus : UILabel!{
        didSet {
            lblStatus.numberOfLines = 0
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
    }
    
    func setStatusLabel(date : Date,expireDate : Date, isRequested : Bool) -> String{
        var remove7DaysComponents = DateComponents()
        remove7DaysComponents.day = -7
        let sevenDaysAgo = Calendar.current.date(byAdding: remove7DaysComponents, to: expireDate)
        if date >= expireDate{
            lblStatus.isHidden = true
            lblExpired.isHidden = false
            return ""
        }else if date < sevenDaysAgo!{
            lblStatus.isHidden = false
            lblExpired.isHidden = true
            return ""
        }else if date >= sevenDaysAgo! && date < expireDate{
            lblStatus.isHidden = false
            lblExpired.isHidden = true
            return " Expiring soon "
        }else if isRequested{
            lblStatus.isHidden = false
            lblExpired.isHidden = true
            return " Requested "
        }
        return ""
    }

}
