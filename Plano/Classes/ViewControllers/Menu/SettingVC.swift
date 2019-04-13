//
//  SettingsVC.swift
//  Plano
//
//  Created by Paing on 1/3/18.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PKHUD
import PopupDialog
import RealmSwift

class SettingsVC: _BaseViewController {
    
    @IBOutlet weak var btnAlerts: UIButton!
    @IBOutlet weak var btnLanguages: UIButton!
    @IBOutlet weak var btnLogout: AdaptiveButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuNavBarWithAttributes(navtitle: "Settings".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        
        self.btnAlerts.setTitle(self.btnAlerts.titleLabel?.text!.localized(), for: .normal)
        self.btnLanguages.setTitle(self.btnLanguages.titleLabel?.text!.localized(), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func btnAlertTapped(_ sender: Any) {
        let vc = UIStoryboard.AlertSettings()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLanguagesTapped(_ sender: Any) {
        let vc = UIStoryboard.LanguageSetting()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogoutTapped(_ sender: Any)
    {
        self.showLogOutPopUp()
    }
    
    // MARK: - Popup
    func showLogOutPopUp(){
        // Confirmation
        let title = "Log out".localized()
        let message = "You are about to log out, do you wish to proceed?".localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "CANCEL".localized()) {}
        let buttonTwo = DefaultButton(title: "PROCEED".localized()) {
            
            self.doLogOut()
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = UIColor.black
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        popup.addButtons([buttonOne,buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    // MARK: - LOG OUT
    func doLogOut(){
        
       
      
        MenuViewModel().logOut(success: { _ in
            
            NotificationsList.clearNotificationData()
            
            // bring to login screen
            
            let nav = UIStoryboard.AuthNav()
            
            if let window = UIApplication.shared.keyWindow
            {
                if let vc = nav.children.first
                {
                    window.rootViewController = nav
                    UIView.transition(from: self.view, to: vc.view, duration: 1.0, options: [.transitionCrossDissolve], completion: {
                        _ in
                        
                    })
                }
            }
            
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
        
        
        
    }
}
