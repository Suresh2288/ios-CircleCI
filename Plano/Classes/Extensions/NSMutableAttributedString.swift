//
//  NSMutableAttributedString.swift
//  SkyPremium
//
//  Created by Thiha Aung on 9/21/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors

extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String,_ size:CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontBook.Bold.of(size: size)]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs))
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String) -> NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
    @discardableResult func normal(_ text:String,_ size:CGFloat) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.font) : FontBook.Regular.of(size: size)]
        let normal = NSMutableAttributedString(string:"\(text)", attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs))
        self.append(normal)
        return self
    }
    @discardableResult func color(_ text:String,_ hex:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.init(hexString: hex)!]
        let str = NSMutableAttributedString(string:"\(text)", attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs))
        self.append(str)
        return self
    }
    @discardableResult func color(_ text:String,_ hex:String,_ size:CGFloat,_ isBold:Bool?) -> NSMutableAttributedString {
        let bold = isBold == nil ? false : isBold!
        let fontName = bold ? FontBook.Bold.of(size: size) : FontBook.Regular.of(size: size)
        let attrs:[String:AnyObject] = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.init(hexString: hex)!, convertFromNSAttributedStringKey(NSAttributedString.Key.font) : fontName]
        let normal = NSMutableAttributedString(string:"\(text)", attributes:convertToOptionalNSAttributedStringKeyDictionary(attrs))
        self.append(normal)
        return self
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
