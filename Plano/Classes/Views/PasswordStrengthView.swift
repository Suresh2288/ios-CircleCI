//
//  TopAlignedLabel.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import JDAnimationKit

class PasswordStrengthView: UIView {
 
    @IBOutlet weak var weakView: UIView!
    @IBOutlet weak var lblStrength: UILabel!
//    @IBOutlet weak var weakViewWidthConstraint: NSLayoutConstraint!
    
    var strength:PWStrength = .weak {
        didSet {
            switch strength {
            case .weak:
                animateWeak()
            case .strong:
                animateStrong()
            case .stronger:
                animateStronger()
            default:
                animateWeaker()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        strength = .weak
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func animateWeaker() {
        animate(view: weakView, newValue: self.frame.size.width/4, color:Color.Red.instance())
        lblStrength.text = "Weak"
        lblStrength.textColor = Color.Red.instance()
    }
    func animateWeak() {
        animate(view: weakView, newValue: self.frame.size.width/2, color:Color.Red.instance())
        lblStrength.text = "Weak"
        lblStrength.textColor = Color.Red.instance()
    }
    
    func animateStrong() {
        animate(view: weakView, newValue: self.frame.size.width/1.35, color:Color.Green.instance())
        lblStrength.text = "Strong"
        lblStrength.textColor = Color.Green.instance()
    }
    
    func animateStronger() {
        animate(view: weakView, newValue: self.frame.size.width, color:Color.Green.instance())
        lblStrength.text = "Strong"
        lblStrength.textColor = Color.Green.instance()
    }
    
    func animate(view:UIView, newValue:CGFloat, color:UIColor){
        var frame = view.frame
        frame.size.width = newValue

        view.changeAnchorPoint(0, y: 0)
            .changeBounds(frame)
            .changeBgColor(color)
    }
}
