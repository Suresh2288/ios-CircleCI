//
//  PopupRedOutsideSafeAreaVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupRedOutsideSafeAreaVC: _BasePopupViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUsewithPermission(_ sender: Any) {
        showSwitchToParentDialog()
    }
    
    func showSwitchToParentDialog(){
        
        let vc = UIStoryboard.SwitchToParentPopup() as! SwitchToParentVC
        
        vc.checkParentPassword = true
        vc.parentVC = self
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true, completion: nil)
    }

}
