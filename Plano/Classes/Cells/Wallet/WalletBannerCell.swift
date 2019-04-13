//
//  WalletBannerCell.swift
//  Plano
//
//  Created by Thiha Aung on 5/10/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class WalletBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBanner : UIImageView!{
        didSet{
            imgBanner.clipsToBounds = true
            //imgBanner.layer.borderColor = UIColor.lightGray.cgColor
            //imgBanner.layer.borderWidth = 0.5
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    


}
