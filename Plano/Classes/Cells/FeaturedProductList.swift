//
//  FeaturedProductList.swift
//  Plano
//
//  Created by John Raja on 02/08/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit

class FeaturedProductList: UICollectionViewCell {
    @IBOutlet weak var imageIs: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var vw_Outer: UIView!
    @IBOutlet weak var MerchantName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.vw_Outer.layer.borderColor = UIColor.lightGray .cgColor
        self.vw_Outer.layer.borderWidth = 0.5
    }

}
