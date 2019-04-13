//
//  ChildProfileCollectionViewCell_4Inch.swift
//  Plano
//
//  Created by Thiha Aung on 7/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class ChildProfileCollectionViewCell_4Inch: BaseChildProfileCollectionViewCell {
    @IBOutlet weak var stk_PlanoShop_Outlet: UIStackView!
    
    @IBOutlet weak var imgChildProfile : UIImageView!{
        didSet{
            imgChildProfile.layer.cornerRadius = imgChildProfile.frame.size.width / 2;
            imgChildProfile.clipsToBounds = true
        }
    }
    @IBOutlet weak var lblChildName : UILabel!{
        didSet{
            lblChildName.numberOfLines = 0
        }
    }
    @IBOutlet weak var btnChildProgress : UIButton!
    @IBOutlet weak var lblChildProgress : UILabel!{
        didSet{
            lblChildProgress.numberOfLines = 0
        }
    }
    @IBOutlet weak var btnSettings : UIButton!
    @IBOutlet weak var lblSettings : UILabel!{
        didSet{
            lblSettings.numberOfLines = 0
        }
    }
    @IBOutlet weak var btnShop : UIButton!
    @IBOutlet weak var lblShop : UILabel!{
        didSet{
            lblShop.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4.0
    }
}
