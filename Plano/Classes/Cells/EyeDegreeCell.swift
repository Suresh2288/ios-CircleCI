//
//  EyeDegreeCell.swift
//  Plano
//
//  Created by Paing Pyi on 31/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class EyeDegreeCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    
    func config(data:ListEyeDegrees){
        lblTitle.text = data.EyeDegreeDescription
    }
}
