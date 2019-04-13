//
//  PopupRestBonusVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupRestBonusVC: _BasePopupBreakViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUseNowClicked(_ sender: Any) {
        dismiss()
        useDeviceNowWithoutAnyRewardOrPanelty()
    }
    @IBAction func btnCloseClicked(_ sender: Any) {
        dismiss()
        useDeviceNowWithoutAnyRewardOrPanelty()
    }
    
    func useDeviceNowWithoutAnyRewardOrPanelty(){
        ChildSessionManager.sharedInstance.useDeviceNowWithoutAnyRewardOrPanelty()
    }
    
    override func updateTimerView(_ notification:Notification){
        
        if let value = notification.object as? String {
            
            let wholeStr = "100 points! \(value)."
            let str = NSMutableAttributedString(string: wholeStr)
            
            let r = (wholeStr as NSString).range(of: value)
            str.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: r)
            
            // display in Main queue for UI
            DispatchQueue.main.async {
                self.lblTimer.attributedText = str
            }
        }
    }
}
