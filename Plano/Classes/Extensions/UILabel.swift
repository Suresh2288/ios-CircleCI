//
//  UILabel.swift
//  Plano
//
//  Created by Paing Pyi on 18/3/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device

extension UILabel {
    
    func getCalculatedPoint(_ factor:CGFloat) -> CGFloat {
        return self.font.pointSize + (self.font.pointSize*factor)
    }
    func getDynamicFontSize(_ factor:CGFloat) -> CGFloat {
        if (Device.size() >= .screen7_9Inch) {
            // iPad - multiply with a default point
            return getCalculatedPoint(factor) // 3 point bigger than iPhones
        }else{
            // iPhone - keep existing point
            return self.font.pointSize
        }
    }
    public func getLabelFontSize() -> CGFloat {
        return getDynamicFontSize(Constants.getDynamiciPadFontFactor()) // 3 point bigger than iPhones
    }
    public func getButtonFontSize() -> CGFloat {
        return getDynamicFontSize(Constants.getDynamiciPadFontFactorButton()) // 3 point bigger than iPhones
    }
}
