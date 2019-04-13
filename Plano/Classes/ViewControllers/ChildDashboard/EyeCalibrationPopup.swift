//
//  EyeCalibrationPopup.swift
//  Plano
//
//  Created by Paing Pyi on 17/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class EyeCalibrationPopup : _BaseViewController {
    
    @IBOutlet weak var lblTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cp = ActiveChildProfile.getProfileObj(){
            self.lblTitle.text = "Hello \(cp.firstName)!".localized()
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss(animated: true) {
            if let parent = self.parentVC as? ChildDashboardVC {
                parent.perform(#selector(parent.userSkipCalibration))
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
