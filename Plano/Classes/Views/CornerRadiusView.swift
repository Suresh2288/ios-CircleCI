//
//  CornerRadius.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/30/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class CornerRadiusView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
   
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Selected / Unselected State
        self.layer.cornerRadius = cornerRadius
        
    }

}
