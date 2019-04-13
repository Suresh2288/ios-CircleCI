//
//  CustomiseSettingsVC.swift
//  Plano
//
//  Created by Thiha Aung on 6/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import CoreLocation
import PopupDialog
import Device

class CustomiseSettingsVC: _BaseViewController {
    
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var customiseSettingView : UIView!
    
    @IBOutlet weak var tblSchedule : UITableView!
    @IBOutlet weak var tblBlockApps : UITableView!
    @IBOutlet weak var tblLocationBoundaries : UITableView!
    @IBOutlet weak var tblSave : UITableView!
    
    //@IBOutlet weak var tblScheduleHeight : NSLayoutConstraint!
    //@IBOutlet weak var tblBlockAppsHeight : NSLayoutConstraint!
    @IBOutlet weak var tblLocationBoundariesHeight : NSLayoutConstraint!
    @IBOutlet weak var tblSaveHeight : NSLayoutConstraint!

    @IBOutlet weak var customiseSettingsScrollView : UIScrollView!
    
    // iPhone X Support
    @IBOutlet weak var titleTopConstraint : NSLayoutConstraint!
    
    var customiseSettings : CustomiseSettings!
    var scheduleSettings : Results<ScheduleSettingsData>!
    var locationSettings : Results<LocationSettingsData>!
    var viewModel = CustomiseSettingsViewModel()
    
    var requiredSelectedSection : Int?
    
    var isPresented : Bool = false
    var childID : Int = 0
   
    //MARK: - Editing
    var selectedScheduleID : Int = 0
    var selectedLocationID : Int = 0

    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color = UIColor.black
        let blackTrans = UIColor.withAlphaComponent(color)(0.8)
        customiseSettingView.backgroundColor = blackTrans

        setUpScheduleTableView()
        setUpBlockAppsTableView()
        setUpLocationTableView()
        startUpCustomiseSettingsView()
        
        viewModelCallBacks()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPresented{
            getCustomiseSettings()
            isPresented = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Device.size() == .screen5_8Inch{
            titleTopConstraint.constant = 55
        }else{
            titleTopConstraint.constant = 30
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Initial Setup
    func startUpCustomiseSettingsView(){
        
        lblTitle.text = "Refine Settings".localized()
        
        viewModel.childID = childID
        viewModel.scheduleActive = 0
        viewModel.blockAppActive = 0
        viewModel.locationActive = 0
        
        //tblSchedule.reloadData()
        //tblScheduleHeight.constant = tblSchedule.contentSize.height
        
        //tblBlockApps.reloadData()
        //tblBlockAppsHeight.constant = tblSchedule.contentSize.height
        
        tblLocationBoundaries.reloadData()
        tblLocationBoundariesHeight.constant = tblLocationBoundaries.contentSize.height
        
        tblSave.reloadData()
        tblSaveHeight.constant = 0
        
        customiseSettingsScrollView.layoutIfNeeded()
    }
    
    //MARK: - TableViews Setups
    func setUpScheduleTableView(){
        
        tblSchedule.register(UINib(nibName : "ScheduleHeaderCell", bundle : nil), forCellReuseIdentifier: "ScheduleHeaderCell")
        tblSchedule.register(UINib(nibName : "ScheduleCell", bundle : nil), forCellReuseIdentifier: "ScheduleCell")
        tblSchedule.register(UINib(nibName : "ScheduleFooterCell", bundle : nil), forCellReuseIdentifier: "ScheduleFooterCell")
        
        tblSchedule.estimatedRowHeight = 100
        tblSchedule.rowHeight = UITableView.automaticDimension
        tblSchedule.separatorColor = UIColor.clear
        tblSchedule.isScrollEnabled = false
        tblSchedule.delegate = self
        tblSchedule.dataSource = self
        
    }
    
    func setUpBlockAppsTableView(){
        
        tblBlockApps.register(UINib(nibName : "BlockAppsHeaderCell", bundle : nil), forCellReuseIdentifier: "BlockAppsHeaderCell")
        tblBlockApps.register(UINib(nibName : "BlockAppsCell", bundle : nil), forCellReuseIdentifier: "BlockAppsCell")
        tblBlockApps.register(UINib(nibName : "BlockAppsFooterCell", bundle : nil), forCellReuseIdentifier: "BlockAppsFooterCell")
        
        tblBlockApps.estimatedRowHeight = 117
        tblBlockApps.rowHeight = UITableView.automaticDimension
        tblBlockApps.separatorColor = UIColor.clear
        tblBlockApps.isScrollEnabled = false
        tblBlockApps.delegate = self
        tblBlockApps.dataSource = self
        
    }
    
    func setUpLocationTableView(){
        
        tblLocationBoundaries.register(UINib(nibName : "LocationHeaderCell", bundle : nil), forCellReuseIdentifier: "LocationHeaderCell")
        tblLocationBoundaries.register(UINib(nibName : "LocationCell", bundle : nil), forCellReuseIdentifier: "LocationCell")
        tblLocationBoundaries.register(UINib(nibName : "LocationFooterCell", bundle : nil), forCellReuseIdentifier: "LocationFooterCell")
        
        tblLocationBoundaries.estimatedRowHeight = 100
        tblLocationBoundaries.rowHeight = UITableView.automaticDimension
        tblLocationBoundaries.separatorColor = UIColor.clear
        tblLocationBoundaries.isScrollEnabled = false
        tblLocationBoundaries.delegate = self
        tblLocationBoundaries.dataSource = self
        
    }
    
    func getCustomiseSettings(){
        
        viewModel.getCustomiseSettings(success: { 
            
            // Getting objects
            self.customiseSettings = CustomiseSettings.getCustomiseSettingsObj()
            
            self.locationSettings = LocationSettingsData.getAllLocationSettings()
            self.scheduleSettings = ScheduleSettingsData.getAllScheduleSettings()
            
            // First we need to assign the updated flags to view model
            self.viewModel.scheduleActive = self.customiseSettings.scheduleActive.toIntFlag()!
            self.viewModel.blockAppActive = self.customiseSettings.blockAppActive.toIntFlag()!
            self.viewModel.locationActive = self.customiseSettings.locationActive.toIntFlag()!
            self.viewModel.custSettingID = Int(self.customiseSettings.custSettingID)
            
            self.viewModel.getAppRating(success: { (_) in
                if self.customiseSettings.childRating != ""{
                    self.viewModel.selectedAppRating = AppRatingMDM.getRatingObjByID(ratingID: Int(self.customiseSettings.childRating)!)
                    
                    UIView.transition(with: self.tblBlockApps, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                        //self.tblBlockApps.reloadData()
                        //self.tblBlockAppsHeight.constant = self.tblBlockApps.contentSize.height
                        
                    }, completion: nil)
                }
            }) {[weak self](msg) in
                self?.showAlert(msg)
            }
            
            // Then reload each table
            UIView.transition(with: self.tblSchedule, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                //self.tblSchedule.reloadData()
                //self.tblScheduleHeight.constant = self.tblSchedule.contentSize.height
                
            }, completion: nil)
            
            UIView.transition(with: self.tblBlockApps, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                //self.tblBlockApps.reloadData()
                //self.tblBlockAppsHeight.constant = self.tblBlockApps.contentSize.height
                
            }, completion: nil)
            
            UIView.transition(with: self.tblLocationBoundaries, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                self.tblLocationBoundaries.reloadData()
                self.tblLocationBoundariesHeight.constant = self.tblLocationBoundaries.contentSize.height
                
            }, completion: nil)
            
            UIView.transition(with: self.tblSave, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
                self.tblSave.reloadData()
                self.tblSaveHeight.constant = 0
                
            }, completion: nil)
            
            self.customiseSettingsScrollView.layoutIfNeeded()
            
            if self.requiredSelectedSection != nil{
                if self.requiredSelectedSection == 0{
                    self.customiseSettingsScrollView.scrollsToTop = true
                    self.requiredSelectedSection = nil
                }else if self.requiredSelectedSection == 1{
                    let schedulePoint : CGPoint = self.customiseSettingsScrollView.convert(.zero, from: self.tblBlockApps)
                    self.customiseSettingsScrollView.setContentOffset(schedulePoint, animated: true)
                    self.requiredSelectedSection = nil
                }else{
                    let schedulePoint : CGPoint = self.customiseSettingsScrollView.convert(.zero, from: self.tblLocationBoundaries)
                    self.customiseSettingsScrollView.setContentOffset(schedulePoint, animated: true)
                    self.requiredSelectedSection = nil
                }
            }
            
        }) { (errorMessage) in
            
            self.showAlert(errorMessage)
        }
    }
    
    //MARK: - CallBack
    func viewModelCallBacks(){
        
        viewModel.childID = childID
        
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
    }
    
    //MARK: - Schedules
    @objc func addNewSchedule(_ sender : UIButton){
        UIView.animate(withDuration: 0.05, animations: {
            sender.backgroundColor = UIColor.white
        },completion: { _ in
            sender.backgroundColor = UIColor.clear
            
            if Device.size() >= .screen7_9Inch{
                if let scheduleVC : PopAddSchedulePeriodVC = UIStoryboard.AddSchedulePeriodPopUpiPad() as? PopAddSchedulePeriodVC{
                    scheduleVC.periodelegate = self
                    //                scheduleVC.scheduleID =  self.selectedScheduleID
                    scheduleVC.modalPresentationStyle = .overFullScreen
                    scheduleVC.modalTransitionStyle = .crossDissolve
                    self.present(scheduleVC, animated: true, completion: nil)
                }
            }else{
                if let scheduleVC : PopAddSchedulePeriodVC = UIStoryboard.AddSchedulePeriodPopUp() as? PopAddSchedulePeriodVC{
                    scheduleVC.periodelegate = self
                    //                scheduleVC.scheduleID =  self.selectedScheduleID
                    scheduleVC.modalPresentationStyle = .overFullScreen
                    scheduleVC.modalTransitionStyle = .crossDissolve
                    self.present(scheduleVC, animated: true, completion: nil)
                }
            }
            
        })
        
        
    }
    
    @objc func deleteSchedule(_ sender : UIButton){
        
        if scheduleSettings == nil{
            return
        }
        
        viewModel.scheduleID = scheduleSettings[sender.tag].scheduleID
        
        // Confirmation
        let title = "Delete Schedule".localized()
        let message = "Are you sure you want to delete this schedule?".localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "NO".localized()) {}
        let buttonTwo = DefaultButton(title: "YES".localized()) {
            
            self.viewModel.deleteSchedule(success: { (message) in
                
                self.showCompletionAlert(server_message: message, isSuccess : true)
                
            }) { (errorMessage) in
                
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }
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
    
    //MARK: - Block Apps
    @objc func addBlockApp(_ sender : UIButton){
        if Device.size() >= .screen7_9Inch{
            if let vc : AgeRatingPopup = UIStoryboard.AgeRatingPopupViewiPad() as? AgeRatingPopup{
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }else{
            if let vc : AgeRatingPopup = UIStoryboard.AgeRatingPopupView() as? AgeRatingPopup{
                vc.delegate = self
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func changeBlockApp(){
        viewModel.updateBlockApp(success: { 
            
            self.getCustomiseSettings()
            
        }) { (errorMessage, errorCode) in
            
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                    self.getCustomiseSettings()
                }, callBackTwo: {
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                    })
                    
                })
            }
        }
    }
    
    //MARK: - Location Boundaries
    @objc func addNewLocationBoundary(_ sender : UIButton){
        UIView.animate(withDuration: 0.05, animations: {
            sender.backgroundColor = UIColor.white
        },completion: { _ in
            sender.backgroundColor = UIColor.clear
            
            if Device.size() >= .screen7_9Inch{
                let nav = UIStoryboard.PopupMapViewNaviPad()
                if nav.viewControllers.count > 0 {
                    if let vc = nav.viewControllers[0] as? ChildrenLocationVC {
                        vc.mapdelegate = self
                        //                    vc.locationID = self.selectedLocationID
                    }
                    self.present(nav, animated: true, completion: nil)
                }
            }else{
                let nav = UIStoryboard.PopupMapViewNav()
                if nav.viewControllers.count > 0 {
                    if let vc = nav.viewControllers[0] as? ChildrenLocationVC {
                        vc.mapdelegate = self
                        //                    vc.locationID = self.selectedLocationID
                    }
                    self.present(nav, animated: true, completion: nil)
                }
            }
        })
    }
    
    @objc func deleteLocationBoundary(_ sender : UIButton){
        
        if locationSettings == nil{
            return
        }
        
        viewModel.locationID = locationSettings[sender.tag].locationeID

        // Confirmation
        let title = "Delete Location".localized()
        let message = "Are you sure you want to delete this location?".localized()

        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }

        let buttonOne = DefaultButton(title: "NO".localized()) {}
        let buttonTwo = DefaultButton(title: "YES".localized()) {
            
            self.viewModel.deleteLocation(success: { (message) in
                
                self.showCompletionAlert(server_message: message, isSuccess : true)
                
            }) { (errorMessage,errorCode) in
                
                if self.isPremiumValid(errorCode: Int(errorCode)){
                    self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                }else{
                    self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                        self.getCustomiseSettings()
                    }, callBackTwo: {
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                        })
                        
                    })
                }
            }
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
    
    //MARK: - Close button
    @IBAction func close(_ sender : UIButton){
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .reloadSummaryCustomiseSettings, object: nil, userInfo: nil)
        })
    }
    
    //MARK: - Period to day convertion
    func periodToDayString(period : String) -> String{
        var selectedDay : [String] = []
        let days = period.components(separatedBy: ",")
        
        for i in 0..<days.count{
            if days[i] == "0"{
                selectedDay.append("Every Day")
            }else if days[i] == "1"{
                selectedDay.append("Mon")
            }else if days[i] == "2"{
                selectedDay.append("Tue")
            }else if days[i] == "3"{
                selectedDay.append("Wed")
            }else if days[i] == "4"{
                selectedDay.append("Thu")
            }else if days[i] == "5"{
                selectedDay.append("Fri")
            }else if days[i] == "6"{
                selectedDay.append("Sat")
            }else if days[i] == "7"{
                selectedDay.append("Sun")
            }
        }
        return selectedDay.joined(separator: " ")
    }
    
    
    //MARK: - Popups
    func showCompletionAlert(server_message : String, isSuccess : Bool){
        
        var title = ""
        
        if isSuccess{
             title = "Successful".localized()
        }
        
        let message = server_message.localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
            
            self.getCustomiseSettings()
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    func showValidateAlert(message : String){
        
        let message = message.localized()
        
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonOne.setTitleColor(Color.Cyan.instance(), for: .normal)
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }

}

//MARK: - TableView Delegates and Datasource
extension CustomiseSettingsVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tblSchedule{
            if scheduleSettings == nil{
                return 0
            }
            return scheduleSettings.count
        }else if tableView == self.tblBlockApps{
            if viewModel.selectedAppRating == nil{
                return 0
            }
            return 1
        }else if tableView == self.tblLocationBoundaries{
            if locationSettings == nil{
                return 0
            }
            return locationSettings.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tblSchedule{
            let view = tableView.dequeueReusableCell(withIdentifier: "ScheduleHeaderCell") as! ScheduleHeaderCell
            view.backgroundColor = UIColor.white
            
            view.lblTitle.text = "Schedule".localized()
            if Device.size() >= .screen7_9Inch{
                view.lblDescription.text = "Select the times your child shouldn’t be on a device eg, during meal times, \n homework and school.".localized()
            }else{
                view.lblDescription.text = "Select the times your child shouldn’t be on a device eg, during meal times, homework and school.".localized()
            }
            view.mainScheduleSwitch.delegate = self
            view.mainScheduleSwitch.name = "SchedulesActive"
            
            if customiseSettings != nil{
                view.mainScheduleSwitch.isOn(state: customiseSettings.scheduleActive.toBool()!)
            }
            
            return view
        }else if tableView == self.tblBlockApps{
            let view = tableView.dequeueReusableCell(withIdentifier: "BlockAppsHeaderCell") as! BlockAppsHeaderCell
            view.backgroundColor = UIColor.white
            
            view.lblTitle.text = "Block Apps".localized()
            view.lblDescription.text = "Choose and block apps you don't wish your child to access.".localized()
            view.blockAppsSwitch.delegate = self
            view.blockAppsSwitch.name = "BlockAppsActive"
            
            if customiseSettings != nil{
                view.blockAppsSwitch.isOn(state: customiseSettings.blockAppActive.toBool()!)
            }
            
            return view
        }else if tableView == self.tblLocationBoundaries{
            let view = tableView.dequeueReusableCell(withIdentifier: "LocationHeaderCell") as! LocationHeaderCell
            view.backgroundColor = UIColor.white
            
            view.lblTitle.text = "Location".localized()
            view.lblDescription.text = "Create a safe area for your child to use the device.".localized()
            
            view.locationBoundariesSwitch.delegate = self
            view.locationBoundariesSwitch.name = "LocationActive"
            
            if customiseSettings != nil{
                view.locationBoundariesSwitch.isOn(state: customiseSettings.locationActive.toBool()!)
            }
            
            return view
        }else{
            let view = tableView.dequeueReusableCell(withIdentifier: "SaveSettingsCell") as! SaveSettingsCell
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tblSchedule{
            return 0.0
            if Device.size() <= .screen4Inch{
                return 130.0
            }else if Device.size() >= .screen7_9Inch{
                return 150.0
            }else{
                return 120.0
            }
        }else if tableView == self.tblLocationBoundaries{
            if Device.size() >= .screen7_9Inch{
                return 150.0
            }else{
                return 134.0
            }
        }else{
            if Device.size() <= .screen4Inch{
                return 120.0
            }
            return 102.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tblBlockApps{
            if viewModel.selectedAppRating == nil{
                return 0
            }
            return 117.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblSchedule{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell
            let schedule = scheduleSettings[indexPath.row]
            
            cell.lblScheduleTitle.text = schedule.titleText
            cell.lblScheduleDay.text = periodToDayString(period: schedule.schedulePeriod)
            if let ft = schedule.fromTime.convertFromUTCTimestamp(), let tt = schedule.toTime.convertFromUTCTimestamp() {
                cell.lblScheduleTime.text = ft + " - " + tt
            }else{
                cell.lblScheduleTime.text = " - "
            }
            
            cell.btnDelete.addTarget(self, action: #selector(CustomiseSettingsVC.deleteSchedule(_:)), for: .touchUpInside)
            cell.btnDelete.tag = indexPath.row
            
            cell.scheduleTypeSwitch.delegate = self
            cell.scheduleTypeSwitch.name = "Schedule"
            cell.scheduleTypeSwitch.tag = schedule.scheduleID
            cell.scheduleTypeSwitch.isOn(state: schedule.active.toBool()!)
            
            return cell
        }else if tableView == self.tblBlockApps{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockAppsCell") as! BlockAppsCell
            
            cell.lblAppTitle.text = viewModel.selectedAppRating?.RatingName
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
            let location = locationSettings[indexPath.row]
            
            cell.lblLocationTitle.text = location.descriptionText
            
            cell.btnDelete.addTarget(self, action: #selector(CustomiseSettingsVC.deleteLocationBoundary(_:)), for: .touchUpInside)
            cell.btnDelete.tag = indexPath.row
            
            cell.locationTypeSwitch.delegate = self
            cell.locationTypeSwitch.name = "Location"
            cell.locationTypeSwitch.tag = location.locationeID
            cell.locationTypeSwitch.isOn(state: location.active.toBool()!)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.tblSchedule{
            selectedScheduleID = scheduleSettings[indexPath.row].scheduleID
            
            if Device.size() >= .screen7_9Inch{
                if let scheduleVC : PopAddSchedulePeriodVC = UIStoryboard.AddSchedulePeriodPopUpiPad() as? PopAddSchedulePeriodVC{
                    scheduleVC.periodelegate = self
                    scheduleVC.scheduleID = self.selectedScheduleID
                    scheduleVC.modalPresentationStyle = .overFullScreen
                    scheduleVC.modalTransitionStyle = .crossDissolve
                    self.present(scheduleVC, animated: true, completion: nil)
                }
            }else{
                if let scheduleVC : PopAddSchedulePeriodVC = UIStoryboard.AddSchedulePeriodPopUp() as? PopAddSchedulePeriodVC{
                    scheduleVC.periodelegate = self
                    scheduleVC.scheduleID = self.selectedScheduleID
                    scheduleVC.modalPresentationStyle = .overFullScreen
                    scheduleVC.modalTransitionStyle = .crossDissolve
                    self.present(scheduleVC, animated: true, completion: nil)
                }
            }
            
        }else if tableView == self.tblBlockApps{
            if Device.size() >= .screen7_9Inch{
                if let vc : AgeRatingPopup = UIStoryboard.AgeRatingPopupViewiPad() as? AgeRatingPopup{
                    vc.delegate = self
                    vc.selectedObj = viewModel.selectedAppRating
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                if let vc : AgeRatingPopup = UIStoryboard.AgeRatingPopupView() as? AgeRatingPopup{
                    vc.delegate = self
                    vc.selectedObj = viewModel.selectedAppRating
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }else if tableView == self.tblLocationBoundaries{
            selectedLocationID = locationSettings[indexPath.row].locationeID
            
            if Device.size() >= .screen7_9Inch{
                let nav = UIStoryboard.PopupMapViewNaviPad()
                if nav.viewControllers.count > 0 {
                    if let vc = nav.viewControllers[0] as? ChildrenLocationVC {
                        vc.mapdelegate = self
                        vc.locationID = self.selectedLocationID
                    }
                    self.present(nav, animated: true, completion: nil)
                }
            }else{
                let nav = UIStoryboard.PopupMapViewNav()
                if nav.viewControllers.count > 0 {
                    if let vc = nav.viewControllers[0] as? ChildrenLocationVC {
                        vc.mapdelegate = self
                        vc.locationID = self.selectedLocationID
                    }
                    self.present(nav, animated: true, completion: nil)
                }
            }
        }else{
            // do nothing
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == self.tblSchedule{
            let view = tableView.dequeueReusableCell(withIdentifier: "ScheduleFooterCell") as! ScheduleFooterCell
            view.backgroundColor = UIColor.white
            
            view.lblTitleInfo.text = "Add a new schedule".localized()
            view.lblTimeInfo.text = "Set a day".localized()
            view.lblDayInfo.text = "Set a time".localized()
            
            view.btnAddSchedule.addTarget(self, action: #selector(CustomiseSettingsVC.addNewSchedule(_:)), for: .touchUpInside)
            
            return view
        }else if tableView == self.tblBlockApps{
            let view = tableView.dequeueReusableCell(withIdentifier: "BlockAppsFooterCell") as! BlockAppsFooterCell
            view.backgroundColor = UIColor.white
            
            view.lblTitleInfo.text = "Choose and block apps".localized()
            view.btnChooseBlockApps.addTarget(self, action: #selector(CustomiseSettingsVC.addBlockApp(_:)), for: .touchUpInside)
            
            return view
        }else if tableView == self.tblLocationBoundaries{
            let view = tableView.dequeueReusableCell(withIdentifier: "LocationFooterCell") as! LocationFooterCell
            view.backgroundColor = UIColor.white
            
            view.lblTitleInfo.text = "Create new area".localized()
            view.btnCreateNewArea.addTarget(self, action: #selector(CustomiseSettingsVC.addNewLocationBoundary(_:)), for: .touchUpInside)
            
            return view
        }else{
            let view = tableView.dequeueReusableCell(withIdentifier: "SaveSettingsCell") as! SaveSettingsCell
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == self.tblSchedule{
            if Device.size() >= .screen7_9Inch{
                return 135.0
            }else{
                return 115.0
            }
        }else if tableView == self.tblBlockApps{
            if viewModel.selectedAppRating == nil{
                return 94.0
            }
            return 0
        }else if tableView == self.tblLocationBoundaries{
            return 94.0
        }else{
            return 0
        }
    }
}

//MARK: - MaterialSwitchDelegate
extension CustomiseSettingsVC : MaterialSwitchDelegate{
    func switchDidChangeState(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        if currentSwitch.name == "SchedulesActive"{
            viewModel.scheduleActive = currentState.rawValue
            viewModel.updateScheduele(success: { 
                
                self.getCustomiseSettings()
                
            }) { (errorMessage, errorCode) in
                
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                
            }
        }else if currentSwitch.name == "BlockAppsActive"{
            if currentState.rawValue == 1{
                showAlert("", "Please be aware that this feature might displace all apps in the phone folders once activated.".localized(), "CANCEL", "PROCEED", callBackOne: {
                    self.getCustomiseSettings()
                }, callBackTwo: {
                    self.viewModel.blockAppActive = currentState.rawValue
                    self.changeBlockApp()
                })
            }else{
                self.viewModel.blockAppActive = currentState.rawValue
                self.changeBlockApp()
            }
        }else if currentSwitch.name == "LocationActive"{
            viewModel.locationActive = currentState.rawValue
            viewModel.updateLocationBoundaries(success: { 
                
                self.getCustomiseSettings()
                
            }) { (errorMessage, errorCode) in
                
                if self.isPremiumValid(errorCode: Int(errorCode)){
                    self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                }else{
                    self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                        self.getCustomiseSettings()
                    }, callBackTwo: {
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                        })
                        
                    })
                }
                
            }
        }else if currentSwitch.name == "Schedule"{
            viewModel.scheduleID = currentSwitch.tag
            viewModel.subScheduleActive = String(currentState.rawValue)
            viewModel.updateSubScheduleActive(success: {
                self.getCustomiseSettings()
            }, failure: { (errorMessage) in
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            })
        }else{
            viewModel.locationID = currentSwitch.tag
            viewModel.subLocationActive = String(currentState.rawValue)
            viewModel.updateSubLocationActive(success: {
                self.getCustomiseSettings()
            }, failure: { (errorMessage,errorCode) in
                if self.isPremiumValid(errorCode: Int(errorCode)){
                    self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                }else{
                    self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                        self.getCustomiseSettings()
                    }, callBackTwo: {
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                        })
                        
                    })
                }
            })
        }
    }
}

//MARK: - UserPeriodDelegate
extension CustomiseSettingsVC : userperiodDelegate{
    func didPeriodData(_ SchedulePeriod: String, _ FromTime: String, _ ToTime: String, _ ScheduleTitle: String) {
        
        viewModel.scheduleTitle = ScheduleTitle
        viewModel.schedulePeriod = SchedulePeriod
        viewModel.fromTime = FromTime
        viewModel.toTime = ToTime
        viewModel.createSchedule(success: { 
            
            self.getCustomiseSettings()
            
        }) { (errorMessage) in
            
            self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
        }
    }
    
    func didDataUpdated(_ ScheduleID: Int, _ SchedulePeriod: String, _ FromTime: String, _ ToTime: String, _ ScheduleTitle: String) {
        viewModel.scheduleID = ScheduleID
        viewModel.scheduleTitle = ScheduleTitle
        viewModel.schedulePeriod = SchedulePeriod
        viewModel.fromTime = FromTime
        viewModel.toTime = ToTime
        viewModel.updateSchedule(success: { 
            
            self.getCustomiseSettings()
            
        }) { (errorMessage) in
            
            self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
        }
    }
}

//MARK: - UserLocationMapDelegate
extension CustomiseSettingsVC : userLocationMapDelegate{
    func didRecieveMapData(_ boundaryName: String, _ placeID: String, _ userMapPosition: CLLocationCoordinate2D, _ Address: String, _ AddressTitle: String, _ description: String, _ boundarySize: String) {
        
        viewModel.locationDescription = boundaryName
        viewModel.placeID = placeID
        viewModel.latitude = userMapPosition.latitude
        viewModel.longitude = userMapPosition.longitude
        viewModel.address = Address
        viewModel.addressTitle = AddressTitle
        viewModel.zoomsize = Int(boundarySize)
        
        viewModel.createLocation(success: { 
            
            self.getCustomiseSettings()
            
        }) { (errorMessage,errorCode) in
            
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                    self.getCustomiseSettings()
                }, callBackTwo: {
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                    })
                    
                })
            }
        }
    }
    
    func didUpdateMapData(_ locationID: Int, _ boundaryName: String, _ placeID: String, _ userMapPosition: CLLocationCoordinate2D, _ Address: String, _ AddressTitle: String, _ description: String, _ boundarySize: String) {
        
        viewModel.locationID = locationID
        viewModel.locationDescription = boundaryName
        viewModel.placeID = placeID
        viewModel.latitude = userMapPosition.latitude
        viewModel.longitude = userMapPosition.longitude
        viewModel.address = Address
        viewModel.addressTitle = AddressTitle
        viewModel.zoomsize = Int(boundarySize)
        viewModel.locationActiveByID = UpdatedLocationsList.getLocationObjByID(locationID: locationID)?.Active.toBool()
        
        viewModel.updateLocation(success: { 
            
            self.getCustomiseSettings()
            
        }) { (errorMessage,errorCode) in
            
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                    self.getCustomiseSettings()
                }, callBackTwo: {
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                    })
                    
                })
            }
        }
        
    }
}

extension CustomiseSettingsVC: AgeRatingDelegate {
    func didRecieveAppRatingData(data: AppRatingMDM) {
        viewModel.appRating = String(data.RatingID)
        viewModel.updateBlockiOSApp(success: {
            self.getCustomiseSettings()
        }, failure: { (errorMessage,errorCode) in
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL", "SIGN UP", callBackOne: {
                    self.getCustomiseSettings()
                }, callBackTwo: {
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .goSignUp, object: nil, userInfo: nil)
                    })
                    
                })
            }
        })
    }
}


