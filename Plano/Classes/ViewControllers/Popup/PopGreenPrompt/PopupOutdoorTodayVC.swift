//
//  PopupOutdoorTodayVC.swift
//  PopViewPlanoTest
//
//  Created by Toe Wai Aung on 5/31/17.
//  Copyright © 2017 kotoeymb. All rights reserved.
//

import UIKit

class PopupOutdoorTodayVC: _BasePopupBreakViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUsewithPermissionClicked(_ sender: Any) {
        showSwitchToParentDialog()
    }
}

class _BasePopupBreakViewController: _BasePopupViewController {

    @IBOutlet weak var lblTimer: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForChildSessionTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterForChildSessionTimer()
    }
    func registerForChildSessionTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimerView(_:)), name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil)
        
    }
    func unRegisterForChildSessionTimer(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ChildSessionManager.timerNotificationIdentifier), object: nil);
    }
    @objc func updateTimerView(_ notification:Notification){
        
        if let value = notification.object as? String {
            
            let wholeStr = "Use device in \(value)."
            let str = NSMutableAttributedString(string: wholeStr)
            
            let r = (wholeStr as NSString).range(of: value)
            str.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: r)
            
            // display in Main queue for UI
            DispatchQueue.main.async {
                self.lblTimer.attributedText = str
            }
        }
    }
    
    /////
    
    func showSwitchToParentDialog(){
        
        let vc = UIStoryboard.SwitchToParentPopup() as! SwitchToParentVC
        
        vc.checkParentPassword = true
        vc.parentVC = self
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true, completion: nil)
    }

}
