//
//  SelectableButton.swift
//  Plano
//
//  Created by Thiha Aung on 5/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton : UIButton{

    @IBInspectable var cornerRadius : CGFloat = 0.0{
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Selected / Unselected State
        self.layer.cornerRadius = cornerRadius
        
        self.backgroundColor = Color.Cyan.instance()
    }
}
