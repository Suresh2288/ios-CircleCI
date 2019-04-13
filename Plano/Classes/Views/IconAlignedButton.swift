//
//  IconAlignedButton.swift
//  Plano
//
//  Created by Thiha Aung on 4/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

@IBDesignable
class IconAlignedButton : UIButton{
    @IBInspectable var cornerRadius : CGFloat = 0.0{
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
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
    
    @IBInspectable var titleLeftPadding : CGFloat = 0.0{
        didSet {
            titleEdgeInsets.left = titleLeftPadding
        }
    }
    
    @IBInspectable var titleRightPadding : CGFloat = 0.0{
        didSet {
            titleEdgeInsets.right = titleRightPadding
        }
    }
    
    @IBInspectable var titleTopPadding : CGFloat = 0.0{
        didSet {
            titleEdgeInsets.top = titleTopPadding
        }
    }
    
    @IBInspectable var titleBottomPadding : CGFloat = 0.0{
        didSet {
            titleEdgeInsets.bottom = titleBottomPadding
        }
    }
    
    @IBInspectable var imageLeftPadding : CGFloat = 0.0{
        didSet {
            imageEdgeInsets.left = imageLeftPadding
        }
    }
    
    @IBInspectable var imageRightPadding : CGFloat = 0.0{
        didSet {
            imageEdgeInsets.right = imageRightPadding
        }
    }
    
    @IBInspectable var imageTopPadding : CGFloat = 0.0{
        didSet {
            imageEdgeInsets.top = imageTopPadding
        }
    }
    
    @IBInspectable var imageBottomPadding : CGFloat = 0.0{
        didSet {
            imageEdgeInsets.bottom = imageBottomPadding
        }
    }
    
    
    @IBInspectable var enableImageLeftAligned : Bool = false
    @IBInspectable var enableImageRightAligned : Bool = false    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 2
        
        // For Left Alignemnt
        if enableImageLeftAligned,
            let imageView = imageView {
            imageEdgeInsets.right = self.bounds.width - imageView.bounds.width - imageLeftPadding
        }
        
        if enableImageRightAligned,
            let imageView = imageView {
            imageEdgeInsets.left = self.bounds.width - imageView.bounds.width - imageRightPadding
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Touch
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        self.backgroundColor = UIColor.lightGray
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        self.backgroundColor = UIColor.clear
//    }
}
