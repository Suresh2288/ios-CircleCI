//
//  PopupRedTooCloseVC.swift
//  PopViewPlanoTest
//
//  Created by Paing on 5/31/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class PopupRedTooCloseVC: _BasePopupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSkipClicked(_ sender: Any) {        
        // quit
        dismiss(animated: true) {
            if let parent = self.parentVC as? ChildDashboardVC {
                parent.perform(#selector(parent.userSkipCalibrationDeductPoint))
            }
        }
    }
    
    @IBAction func btnCalibrateClicked(_ sender: Any) {
        dismiss(animated: true) {
            if let parent = self.parentVC as? ChildDashboardVC {
                parent.perform(#selector(parent.startEyeCalibration))
            }
        }
    }
}
