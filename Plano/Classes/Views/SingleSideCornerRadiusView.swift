//
//  SingleSideCornerRadiusView.swift
//  PopViewPlanoTest
//
//  Created by Paing on 6/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class SingleSideCornerRadiusView: UIView {
    
    var leftSideBool = false
    var rightSideBool = false
    
    @IBInspectable var leftSide: Bool {
        get {
            return leftSideBool
        }
        set {
            leftSideBool = newValue
            drawCornerRadius(leftSide: leftSideBool, rightSide: rightSideBool)
        }
    }
    @IBInspectable var rightSide: Bool {
        get {
            return rightSideBool
        }
        set {
            rightSideBool = newValue
            drawCornerRadius(leftSide: leftSideBool, rightSide: rightSideBool)
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

        drawCornerRadius(leftSide: leftSideBool, rightSide: rightSideBool)
    }
    
    func drawCornerRadius(leftSide:Bool, rightSide:Bool) {
        
        var arr:UIRectCorner = []
        
        if(leftSide && rightSide){
            arr = [.allCorners]
        }else if(leftSide){
            arr = [.topLeft, .bottomLeft]
        }else if(rightSide){
            arr = [.topRight, .bottomRight]
        }
        
        if(leftSide || rightSide){
            let path = UIBezierPath(roundedRect:self.bounds,
                                    byRoundingCorners:arr,
                                    cornerRadii: CGSize(width: self.bounds.height/2, height:  self.bounds.height/2))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
    }
}
