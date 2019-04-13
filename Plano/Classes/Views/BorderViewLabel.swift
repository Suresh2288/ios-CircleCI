//
//  BorderViewLabel.swift
//  Plano
//
//  Created by Thiha Aung on 5/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

@IBDesignable
class BorderViewLabel : UILabel{
    
    @IBInspectable var borderWidth : CGFloat = 0.0{
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = .black{
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

}
