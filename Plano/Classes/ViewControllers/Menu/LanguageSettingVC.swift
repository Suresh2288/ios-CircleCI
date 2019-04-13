//
//  LanguageSettingVC.swift
//  Plano
//
//  Created by Paing on 1/3/18.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift
import Localize_Swift
import SwiftyUserDefaults

class LanguageSettingVC: _BaseViewController {
    
    var selectedLanguage = LanguageManager.sharedInstance.selectedLanguageID()
    
    @IBOutlet weak var imgEn: UIImageView!
    @IBOutlet weak var imgCn: UIImageView!
    @IBOutlet weak var imgKo: UIImageView!
    @IBOutlet weak var imgJp: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Language Settings Page",pageName:"Language Settings Page",actionTitle:"Entered in Language Settings Page")

        setUpNavBarWithAttributes(navtitle: "Alert settings".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        let _ = showBackBtn()
        
        
        // hide at first
        imgEn.isHidden = true
        imgCn.isHidden = true
        imgKo.isHidden = true
        imgJp.isHidden = true
                
        switch selectedLanguage {
        case .chinese:
            btnCnTapped(UIButton())
            break
        case .japanese:
            btnJpTapped(UIButton())
            break
        case .korean:
            btnKoTapped(UIButton())
            break
        default:
            btnEnTapped(UIButton())
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    @IBAction func btnEnTapped(_ sender: Any) {
        selectedLanguage = .english
        
        imgEn.isHidden = false
        imgCn.isHidden = true
        imgKo.isHidden = true
        imgJp.isHidden = true
    }
    
    @IBAction func btnCnTapped(_ sender: Any) {
        selectedLanguage = .chinese
        
        imgEn.isHidden = true
        imgCn.isHidden = false
        imgKo.isHidden = true
        imgJp.isHidden = true
    }
    
    @IBAction func btnKoTapped(_ sender: Any) {
        selectedLanguage = .korean
        
        imgEn.isHidden = true
        imgCn.isHidden = true
        imgKo.isHidden = false
        imgJp.isHidden = true
    }
    
    @IBAction func btnJpTapped(_ sender: Any) {
        selectedLanguage = .japanese
        
        imgEn.isHidden = true
        imgCn.isHidden = true
        imgKo.isHidden = true
        imgJp.isHidden = false
    }


    @IBAction func btnSubmit(_ sender: Any) {
        self.showAlert("", "Are you sure you want to change the language?".localized(), "CANCEL".localized(), "PROCEED".localized(), callBackOne: { 
            //  do nothing
        }, callBackTwo: {
            
            self.showAlert("The app is required to be \nrestarted in order to display the selected language properly. \nPlease clear the app from \nApp Switcher and open again.".localized())

            // set to new language
            LanguageManager.sharedInstance.setCurrentLanguage(self.selectedLanguage)
           
            // update to API
            if let profile = ProfileData.getProfileObj() {
                let data = UpdateLanguageRequest(email: profile.email, accessToken: profile.accessToken)
                APIManager.sharedInstance.updateLanguage(data: data, completed: { (apiResponseHandler, error) in
                    //
                })
            }
            
            self.showParentDashboardLanding()
        })
    }
    
    
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
