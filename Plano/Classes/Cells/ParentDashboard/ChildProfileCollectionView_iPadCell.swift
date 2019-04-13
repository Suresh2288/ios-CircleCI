//
//  ChildProfileCollectionView_iPadCell.swift
//  Plano
//
//  Created by Thiha Aung on 3/29/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class ChildProfileCollectionView_iPadCell: BaseChildProfileCollectionViewCell {
    
    @IBOutlet weak var lblChildMode: UILabel!
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
        
        lblChildMode.text = lblChildMode.text!.localized()
    }
    
}