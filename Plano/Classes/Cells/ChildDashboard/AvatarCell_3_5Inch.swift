//
//  AvatarCell_3_5Inch.swift
//  Plano
//
//  Created by Thiha Aung on 7/19/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Kingfisher

class AvatarCell_3_5Inch: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblPrice: UIButton!
    
    func configCellWithData(data:AvatarItem){
        lblPrice.setTitle(String(data.neededPoint), for: .normal)
        image.kf.setImage(with: URL(string: data.thumbnail), placeholder: nil, options: [.transition(.fade(0.5))])
    }

}
