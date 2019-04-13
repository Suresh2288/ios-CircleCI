//
//  AvatarCell.swift
//  Plano
//
//  Created by Paing Pyi on 31/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Kingfisher

class AvatarCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblPrice: UIButton!
    
    func configCellWithData(data:AvatarItem){
        lblPrice.setTitle(String(data.neededPoint), for: .normal)
        image.kf.setImage(with: URL(string: data.thumbnail), placeholder: nil, options: [.transition(.fade(0.5))])
    }
    
}


