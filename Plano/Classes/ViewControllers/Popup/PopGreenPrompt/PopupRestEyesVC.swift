//
//  PopupRestEyesVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupRestEyesVC: _BasePopupBreakViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnUsewithPermissionClicked(_ sender: Any) {
        showSwitchToParentDialog()
    }

}
