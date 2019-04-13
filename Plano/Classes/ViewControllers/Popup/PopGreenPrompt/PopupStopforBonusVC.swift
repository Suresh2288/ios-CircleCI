//
//  PopupStopforBonusVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupStopforBonusVC: _BasePopupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStopClicked(_ sender: Any) {
        UserDefaults.standard.set("0", forKey: "ExtensionSeconds")
        UserDefaults.standard.synchronize()
        
        ChildSessionManager.sharedInstance.UpdateBreakSessionExtension()
        ChildSessionManager.sharedInstance.stop5MinuteBefore35Minute()
        dismiss()
    }

    @IBAction func btnContinueUsingClicked(_ sender: Any) {
        dismiss()
    }
    
}
