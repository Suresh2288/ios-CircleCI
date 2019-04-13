//
//  Popup5MoreMinutesVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupOrangeMoreMinutesVC: _BasePopupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStopClicked(_ sender: Any) {
        UserDefaults.standard.set("300", forKey: "ExtensionSeconds")
        UserDefaults.standard.synchronize()
        
        ChildSessionManager.sharedInstance.UpdateBreakSessionExtension()
        ChildSessionManager.sharedInstance.stopDeviceUsageNow()
        dismiss()
    }

    @IBAction func btnContinuUsingClicked(_ sender: Any) {
        ChildSessionManager.sharedInstance.continueDeviceUsageFor50Points()
        dismiss()
    }

}
