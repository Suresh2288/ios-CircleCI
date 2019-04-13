//
//  AlertSettingsVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import PKHUD
import RealmSwift
import Device

class AlertSettingsVC: _BaseViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "alertsettings"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "alertsettings"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    @IBOutlet weak var tblAlertSettings : UITableView!
    
    var viewModel = AlertSettingsViewModel()
    var settingData : Results<AlertSettings>!
    var isPresented : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Alert Settings Page",pageName:"Alert Settings Page",actionTitle:"Entered in Alert Settings Page")

//        setupMenuNavBarWithAttributes(navtitle: "Alert settings", setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        setUpNavBarWithAttributes(navtitle: "Alert settings".localized(), setStatusBarStyle: .lightContent, isTransparent: false, tintColor: Color.Cyan.instance(), titleColor: UIColor.white, titleFont: FontBook.Bold.of(size: 16))
        showBackBtn()
        
        setUpAlertSettingsView()
        viewModelCallBack()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isPresented{
            viewModel.getAlertSettings(success: { 
                
                self.settingData = AlertSettings.getSettings()
                
                UIView.transition(with: self.tblAlertSettings, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    
                    self.tblAlertSettings.reloadData()
                    
                }, completion: nil)
                
            }) { (errorMessage) in
                
                self.showAlert(errorMessage)
            }
            isPresented = true
        }
        
    }
    
    func setUpAlertSettingsView(){
        
        tblAlertSettings.register(UINib(nibName : "AlertSettingsCell", bundle : nil), forCellReuseIdentifier: "AlertSettingsCell")
        tblAlertSettings.register(UINib(nibName : "AlertSettingsCelliPad", bundle : nil), forCellReuseIdentifier: "AlertSettingsCelliPad")

        tblAlertSettings.estimatedRowHeight = 100
        tblAlertSettings.rowHeight = UITableView.automaticDimension
        tblAlertSettings.separatorInset.left = 0
        tblAlertSettings.separatorInset.right = 0
        tblAlertSettings.showsVerticalScrollIndicator = false
        tblAlertSettings.tableFooterView = UIView(frame: .zero)
        
    }
    
    
    func viewModelCallBack(){
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
}

extension AlertSettingsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if settingData == nil{
            return 0
        }
        return settingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AlertSettingsCell") as! AlertSettingsCell
        
        if Device.size() >= .screen7_9Inch {
            cell = tableView.dequeueReusableCell(withIdentifier: "AlertSettingsCelliPad") as! AlertSettingsCelliPad
        }
        
        let settings = settingData[indexPath.row]
        
        cell.lblSettingTitle.text = settings.titleText
        cell.lblSettingDescription.text = settings.descriptionText
        cell.materialSwitch.tag = settings.alertID
        cell.materialSwitch.isOn(state: settings.allowPush.toBool()!)
        
        cell.materialSwitch.delegate = self
        
        return cell
    }
}

// MARK: - MaterialSwitchDelegates
extension AlertSettingsVC : MaterialSwitchDelegate{
    
    func switchDidChangeState(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        
        viewModel.alertID = currentSwitch.tag
        viewModel.allowPush = currentState.rawValue.toBool()
        
        viewModel.updateAlertSettings(success: { _ in

            print("Alert Settings Updated")
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
}
