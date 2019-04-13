//
//  SelectableButton.swift
//  Plano
//
//  Created by Thiha Aung on 5/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

@IBDesignable
class SelectableButton : IconAlignedButton{

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(Color.Cyan.instance(), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Selected / Unselected State
        if isSelected {
            backgroundColor = Color.Cyan.instance()
        }else{
            backgroundColor = .white
        }
    }
}
