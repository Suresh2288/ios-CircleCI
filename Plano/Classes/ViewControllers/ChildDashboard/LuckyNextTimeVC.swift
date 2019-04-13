//
//  LuckyNextTimeVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class LuckyNextTimeVC : _BasePopupViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPlayClicked(_ sender: Any) {
        dismiss()
        if let vc = self.parentVC as? PairGameVC {
            if vc.canPerformAction(#selector(vc.popupLuckyNextTime), withSender: nil) {
                vc.perform(#selector(vc.popupLuckyNextTime), with: nil, afterDelay: 0.2)
            }
        }else if let vc = self.parentVC as? EyeGameVC {
            if vc.canPerformAction(#selector(vc.popupLuckyNextTime), withSender: nil) {
                vc.perform(#selector(vc.popupLuckyNextTime), with: nil, afterDelay: 0.2)
            }
        }
    }
    
}
