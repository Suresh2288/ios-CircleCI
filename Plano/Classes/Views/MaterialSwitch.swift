//
//  MaterialSwitch.swift
//  Plano
//
//  Created by Thiha Aung on 5/16/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import JTMaterialSwitch

protocol MaterialSwitchDelegate {
    func switchDidChangeState(currentSwitch : MaterialSwitch, currentState: MaterialSwitchState)
}

enum MaterialSwitchState: Int {
    case Off
    case On
}

@IBDesignable
class MaterialSwitch : UIView {
    
    var name : String = ""
    var matSwitch : JTMaterialSwitch?
    var delegate : MaterialSwitchDelegate?
    
    @IBInspectable var thumbOnTintColor : UIColor = Color.Cyan.instance(){
        didSet{
            matSwitch?.thumbOnTintColor = thumbOnTintColor
        }
    }
    @IBInspectable var trackOnTintColor : UIColor = Color.DarkCyan.instance(){
        didSet{
            matSwitch?.trackOnTintColor = trackOnTintColor
        }
    }
    @IBInspectable var rippleFillColor : UIColor = Color.DarkCyan.instance(){
        didSet{
            matSwitch?.rippleFillColor = rippleFillColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    
    func initView() {
                
        matSwitch = JTMaterialSwitch(size: JTMaterialSwitchSizeNormal, style: JTMaterialSwitchStyleDefault, state: JTMaterialSwitchStateOff)
        
        matSwitch?.thumbOnTintColor = thumbOnTintColor
        matSwitch?.trackOnTintColor = trackOnTintColor
        matSwitch?.rippleFillColor = rippleFillColor
        
        matSwitch?.center = CGPoint(x: self.bounds.midX, y: (matSwitch?.center.y)!)
        matSwitch?.addTarget(self, action: #selector(MaterialSwitch.stateChanged), for: .valueChanged)
        
        addSubview(matSwitch!)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()        
    }
    
    // Return the current state via delegate
    @objc func stateChanged(){
        if matSwitch?.isOn == true{
            delegate?.switchDidChangeState(currentSwitch: self, currentState: .On)
        }else{
            delegate?.switchDidChangeState(currentSwitch: self, currentState: .Off)
        }
    }
    
    // This trigger delegate (valueChanged)
    func setState(state : Bool){
        matSwitch?.setOn(state, animated: true)
    }
    
    // This doesn't trigger delegate (valueChanged)
    func isOn(state : Bool){
        matSwitch?.isOn = state
        matSwitch?.setOn(state, animated: false)
    }
}
