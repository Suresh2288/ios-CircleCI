//
//  AgeRatingCell.swift
//  PopupViewPlano
//
//  Created by Paing Pyi Ko
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class AgeRatingCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgTick: UIImageView!
    
    func config(data:AppRatingMDM){
        lblTitle.text = data.RatingName
        imgTick.isHidden = !data.isSelected
    }
}

