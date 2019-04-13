//
//  PopupWonGameVC.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PopupWonGameVC : _BasePopupViewController {
    
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
    
    @IBAction func btnOKClicked(_ sender: Any) {
        dismiss()
        if let vc = self.parentVC as? PairGameVC {
            if vc.canPerformAction(#selector(vc.popupWonGameDone), withSender: nil) {
                vc.perform(#selector(vc.popupWonGameDone), with: nil, afterDelay: 0.2)
            }
        }else if let vc = self.parentVC as? EyeGameVC {
            if vc.canPerformAction(#selector(vc.popupWonGameDone), withSender: nil) {
                vc.perform(#selector(vc.popupWonGameDone), with: nil, afterDelay: 0.2)
            }
        }
    }
    
}
