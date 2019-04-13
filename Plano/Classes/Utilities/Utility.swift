//
//  Utility.swift
//  Plano
//
//  Created by Paing Pyi on 16/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

enum FontBook: String {
    
    // https://medium.com/jtribe/swift-custom-fonts-slightly-less-awful-f235e20027f3#.f5jjef9wr
    
    case Thin = "Raleway-Thin"
    case Light = "Raleway-Light"
    case ExtraBoldItalic = "Raleway-ExtraBoldItalic"
    case SemiBoldItalic = "Raleway-SemiBoldItalic"
    case Medium = "Raleway-Medium"
    case Regular = "Raleway-Regular"
    case BoldItalic = "Raleway-BoldItalic"
    case SemiBold = "Raleway-SemiBold"
    case ExtraBold = "Raleway-ExtraBold"
    case Italic = "Raleway-Italic"
    case MediumItalic = "Raleway-MediumItalic"
    case ExtraLightItalic = "Raleway-ExtraLightItalic"
    case Bold = "Raleway-Bold"
    case Black = "Raleway-Black"
    case LightItalic = "Raleway-LightItalic"
    case ExtraLight = "Raleway-ExtraLight"
    case ThinItalic = "Raleway-ThinItalic"
    case BlackItalic = "Raleway-BlackItalic"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}

enum Color: String {
    case Cyan = "68ced9"
    case DarkCyan = "48B5C0"
    case FlatCyan = "82CCD7"
    case Gray = "efefef"
    case Red = "E25845"
    case Green = "68BF8F"
    case Magenta = "2c1242"
    case FlatPurple = "5357bc"
    case LiteGrey = "CDCDCD"
    case DarkGrey = "5D5172"
    case FlatOrange = "F7C016"
    case FlatRed = "D93829"
    case FlatMilk = "F2F2F3"
    case Purple = "5B5FBF"
    
    func instance() -> UIColor {
        return UIColor(hexString: self.rawValue)!
    }
}

