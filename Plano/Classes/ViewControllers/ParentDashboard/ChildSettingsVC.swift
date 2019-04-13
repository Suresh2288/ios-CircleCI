//
//  ChildSettingsVC.swift
//  Plano
//
//  Created by Thiha Aung on 5/15/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import JTMaterialSwitch
import Device
import PKHUD
import RealmSwift
import Kingfisher
import PopupDialog
import CoreLocation
import Localize_Swift

class ChildSettingsVC: _BaseScrollViewController {
    
    override var analyticsScreenName:String? {
        get {
            return "childsettings"
        }
        set {
            self.analyticsScreenName = newValue
        }
    }
    
    override var appFlyerScreenName:String? {
        get {
            return "childsettings"
        }
        set {
            self.appFlyerScreenName = newValue
        }
    }
    
    //MARK: - Settings Outlets
    @IBOutlet weak var imgProfile : UIImageView!{
        didSet{
            imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2;
            imgProfile.clipsToBounds = true
        }
    }
    
    
    //MARK: - Settings Outlets
    @IBOutlet weak var lblChildName : UILabel!
    @IBOutlet weak var lblScheduleTitle : UILabel!
    @IBOutlet weak var lblBlockAppsTitle : UILabel!
    @IBOutlet weak var lblBlockBrowserTitle : UILabel!
    @IBOutlet weak var lblLocationBoundaryTitle : UILabel!
    @IBOutlet weak var lblPostureTracking: UILabel!
    @IBOutlet weak var lblBlueLightFilterTitle : UILabel!
    @IBOutlet weak var lblRemotelyLockTitle : UILabel!
    @IBOutlet weak var blockBrowserSwitch : MaterialSwitch!
    @IBOutlet weak var postureTrackingSwitch: MaterialSwitch!
    @IBOutlet weak var btnRemoteLock : UIButton!
    @IBOutlet weak var btnSchedule : UIButton!
    @IBOutlet weak var btnBlockApp : UIButton!
    @IBOutlet weak var btnLocationBoundaries : UIButton!
    @IBOutlet weak var btnBlueLightFilter : UIButton!
    
    @IBOutlet weak var blockBrowserBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postureView: UIView!
    
    //MARK: - Required Variables
    var childID : Int = 0
    var custSettingID : Int = 0
    var progressDate : String = ""
    var dateUsed : String = ""
    var isRemoteLock : Bool = false
    var comeFromNotification : Bool = false
    var isPresented : Bool = false
    var shouldOpenRefineSetting : Bool = false
    
    var viewModel = ChildProgressViewModel()
    var myFamilyViewModel = MyFamilyViewModel()
    
    let placeholderImage = UIImage(named: "iconAvatar")
    
    var locationManager = CLLocationManager()
    var showedLocationMessage = false
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChildSettingsVC.initChildSetting), name: .reloadSummaryCustomiseSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChildSettingsVC.goToPremium), name: .goSignUp, object: nil)
        
        setUpNavBarWithAttributes(navtitle: "Settings".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16))
        shouldFollowScrollView = false
        
        if let profileImage = ChildProfile.getChildProfileById(childId: String(childID))?.profileImage{
            
            imgProfile.kf.setImage(with: URL(string: profileImage), placeholder: placeholderImage,options: [.transition(.fade(0.5))])
        }
        initView()
        viewModelCallBack()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WoopraTrackingPage().trackEvent(mainMode:"Parent Child Settings Page",pageName:"Child Settings Page",actionTitle:"Switching Home Page to Child Settings Page")
        removeLeftMenuGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(isPresented){
            initChildSetting()
            isPresented = true
        }
        if shouldOpenRefineSetting {
            btnBlockScheduleTapped(UIButton())
            shouldOpenRefineSetting = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addLeftMenuGesture()
    }
    
    // MARK: - Initialization
    @objc func initLocationService(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // this is a quite nice function
        // it will trigger to following either of two methods "didUpdateLocations" or "didFailWithError"
        locationManager.requestLocation()
    }
    
    func initView(){
        
        blockBrowserSwitch.tag = 1
        blockBrowserSwitch.delegate = self
        
        /* Posture */
        ///*
        postureTrackingSwitch.delegate = self
        postureTrackingSwitch.tag = 2
        lblPostureTracking.text = "Posture tracking".localized()
        
        // */
        
        //        postureView.isHidden = false
        //        blockBrowserBottomConstraint.constant = 5;
        //        postureView.superview?.layoutIfNeeded()
        /* disabled Posture code ended */
        
        scrollView.delegate = self
        
        if let profile = ChildProfile.getChildProfileById(childId: String(childID)){
            lblChildName.text = profile.firstName + " " + profile.lastName
        }
        
        lblScheduleTitle.text = "Schedule".localized()
        lblBlockAppsTitle.text = "Block apps".localized()
        lblBlockBrowserTitle.text = "Block browser".localized()
        lblLocationBoundaryTitle.text = "Location boundaries".localized()
        
        if Device.size() >= .screen7_9Inch{
            lblRemotelyLockTitle.text = "Remotely lock child's device".localized()
        }else{
            lblRemotelyLockTitle.text = "Remotely lock\nchild's device".localized()
        }
        
        lblBlueLightFilterTitle.text = "Blue light filter".localized()
        
    }
    
    @objc func initChildSetting(){
        viewModel.childID = childID
        
        viewModel.getCustomiseSettingsSummary(success: { 
            
            guard let settingSummaryObj : CustomiseSettingsSummary = CustomiseSettingsSummary.getCustomiseSettingSummaryObj() else{
                return
            }
            
            if settingSummaryObj.isLocationOptionActive() {
                self.perform(#selector(self.initLocationService), with: nil, afterDelay: 0.3)
            }
            
            self.custSettingID = Int(settingSummaryObj.custSettingID)!
            
            self.blockBrowserSwitch.isOn(state: settingSummaryObj.blockBrowserActive.toBool()!)
            
            /* posture */
            if let posture = settingSummaryObj.posture {
                self.postureTrackingSwitch.isOn(state: posture.toBool()!)
            }
            
            
            self.isRemoteLock = settingSummaryObj.childLock.toBool()!
            if self.isRemoteLock{
                self.btnRemoteLock.setImage(UIImage(named : "iconBtnLock"), for: .normal)
            }else{
                self.btnRemoteLock.setImage(UIImage(named : "iconBtnUnlock"), for: .normal)
            }
            
        }) { (errorMessage) in
            
            //load the previous state from realm (Question?)
            self.blockBrowserSwitch.setState(state: false)
            
            /* posture */
            self.postureTrackingSwitch.setState(state: false)
            
            self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
        }
    }
    
    // MARK: - CallBack
    func viewModelCallBack() {
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        myFamilyViewModel.openInSafari = {[weak self](url) in
            self?.showPlanoProfilePopup(url: url)
        }
    }
    
    // MARK: - IBActions
    
    
    @IBAction func btnDeleteChildTapped(_ sender: Any) {
        self.showAlert("", "Are you sure you want to delete your child? All child data will be lost.", "Cancel".localized(), "Delete".localized(), callBackOne: nil, callBackTwo: {
            
            self.viewModel.deleteChild(success: { (message) in
                WoopraTrackingPage().trackEvent(mainMode:"Parent Child Settings Page",pageName:"Child Settings Page",actionTitle:"Delete Child Account")
                
                self.navigationController?.popViewController(animated: true)
            }) { (message) in
                self.showAlert(message)
            }
        })
    }
    
    @IBAction func btnBlockScheduleTapped(_ sender : Any){
        if let vc = UIStoryboard.CustomiseSettings() as? CustomiseSettingsVC{
            WoopraTrackingPage().trackEvent(mainMode:"Parent Child Settings Page",pageName:"Child Settings Page",actionTitle:"Switching Child Settings Page to Refine Settings Block Schedule")
            vc.childID = (self.childID)
            vc.requiredSelectedSection = 0
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBlockAppTapped(_ sender : Any){
        if let vc = UIStoryboard.CustomiseSettings() as? CustomiseSettingsVC{
            WoopraTrackingPage().trackEvent(mainMode:"Parent Child Settings Page",pageName:"Child Settings Page",actionTitle:"Switching Child Settings Page to Refine Settings Block App")
            vc.childID = (self.childID)
            vc.requiredSelectedSection = 1
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBlockLocationTapped(_ sender : Any){
        if let vc = UIStoryboard.CustomiseSettings() as? CustomiseSettingsVC{
            WoopraTrackingPage().trackEvent(mainMode:"Parent Child Settings Page",pageName:"Child Settings Page",actionTitle:"Switching Child Settings Page to Refine Settings Block Location")
            vc.childID = (self.childID)
            vc.requiredSelectedSection = 2
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnBlueLightFilterTapped(_ sender : Any){
        self.showBlueLightAlert()
    }
    
    @IBAction func btnRemoteLockTapped(_ sender: Any) {
        AnalyticsHelper().analyticLogScreen(screen: "remotelock")
        AppFlyerHelper().trackScreen(screenName: "remotelock")
        
        if (self.isRemoteLock){
            print("Unlock")
            self.viewModel.childLock = 0
            self.isRemoteLock = false
            self.updateRemoteLock()
        }else{
            self.showAlert("", "Please be aware that this feature might displace all apps in the phone folders once activated.".localized(), "CANCEL".localized(), "PROCEED".localized(), callBackOne: {
                self.initChildSetting()
            }, callBackTwo: {
                print("Lock")
                self.viewModel.childLock = 1
                self.isRemoteLock = true
                self.updateRemoteLock()
            })
        }
    }
    
    func updateRemoteLock(){
        viewModel.updateChildLock(success: { 
            
            if self.isRemoteLock{
                
                guard let settingSummaryObj : CustomiseSettingsSummary = CustomiseSettingsSummary.getCustomiseSettingSummaryObj() else{
                    return
                }
                
                if settingSummaryObj.childLock == "1"{
                    self.btnRemoteLock.setImage(UIImage(named : "iconBtnLock"), for: .normal)
                }
                
                self.initChildSetting()
                
                
            }else{
                
                self.btnRemoteLock.setImage(UIImage(named : "iconBtnUnlock"), for: .normal)
                
                self.initChildSetting()
                
            }
            
        }) { (errorMessage,errorCode) in
            
            if self.isPremiumValid(errorCode: Int(errorCode)){
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
            }else{
                self.showAlert("", "This function is only available for higher subscription packages.".localized(), "CANCEL".localized(), "SIGN UP".localized(), callBackOne: {
                    self.initChildSetting()
                }, callBackTwo: {
                    self.goToPremium()
                })
            }
            
        }
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
            self.initChildSetting()
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
    
    func showNavigationAlert(server_message : String, sectionIndex : Int){
        
        let title = ""
        
        let message = server_message.localized()
        
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
    
    func showBlueLightAlert(){
        let message = "You will need to activate the Night Shift option in your phone settings to enable your phone's blue light filter. The settings can be found under Settings > Display & Brightness".localized()
        
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: false) {
        }
        
        let buttonOne = DefaultButton(title: "OK".localized()) {
            // do nothing
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
        self.present(popup, animated: true, completion: {
            AnalyticsHelper().analyticLogScreen(screen: "bluelight")
            AppFlyerHelper().trackScreen(screenName: "bluelight")
        })
    }
    
    @objc func goToPremium(){
        if let vc = UIStoryboard.Premium() as? PremiumVC{
            vc.parentVC = self
            vc.comeFromSetting = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func showPlanoProfilePopup(url:URL){
        // Prepare the popup
        let title = "Profile installation".localized()
        let message = "In order to use plano's parental features, please follow Apple's installation process.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL".localized()) {
            //
        }
        let buttonThree = CancelButton(title: "INSTALL".localized()) {
            if #available(iOS 10.0,*){
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }else{
                UIApplication.shared.openURL(url)
            }
        }
        
        if popup.viewController is PopupDialogDefaultViewController {
            if let vc = popup.viewController as? PopupDialogDefaultViewController {
                vc.titleFont = FontBook.Bold.of(size: 17)
                vc.messageFont = FontBook.Regular.of(size: 17)
                vc.titleColor = Color.Magenta.instance()
                vc.messageColor = vc.titleColor
            }
            
        }
        
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonThree,buttonOne])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        
        AnalyticsHelper().analyticLogScreen(screen: "planoprofile")
        
        AppFlyerHelper().trackScreen(screenName: "planoprofile")
        
    }
}

// MARK: - MaterialSwitchDelegates
extension ChildSettingsVC : MaterialSwitchDelegate{
    
    func switchDidChangeState(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        self.viewModel.childID = self.childID
        if currentSwitch.tag == 1{
            AnalyticsHelper().analyticLogScreen(screen: "blockbrowser")
            AppFlyerHelper().trackScreen(screenName: "blockbrowser")
            
            self.viewModel.blockBrowser = currentState.rawValue
            self.viewModel.updateBlockBrowser(success: { 
                
                print("Successfully Updated!!")
                
            }) { (errorMessage) in
                
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                
            }
        }else if currentSwitch.tag == 2{
            AnalyticsHelper().analyticLogScreen(screen: "posture_toggle")
            AppFlyerHelper().trackScreen(screenName: "posture_toggle")
            
            self.viewModel.posture = currentState.rawValue
            self.viewModel.updatePosture(success: { 
                
                print("Successfully Updated!!")
                
            }) { (errorMessage) in
                
                self.showCompletionAlert(server_message: errorMessage, isSuccess : false)
                
            }
        }
    }
    
    func switchDidTouched(currentSwitch: MaterialSwitch, currentState: MaterialSwitchState) {
        
    }
}


// MARK: - CLLocation Delegate
extension ChildSettingsVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied: // authorizedAlways authorizedWhenInUse
            let alertController = UIAlertController(
                title: "Background Location Access Disabled".localized(),
                message: "In order to be notified about child device usage, please open this app's settings and set location access to 'Always'.".localized(),
                preferredStyle: .alert)
            //In order to be notified about adorable kittens near you, please open
            let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Enable".localized(), style: .default) { (action) in
                if let url = NSURL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            self.showLocationAccessPopup() // keep nagging to user to allow "always"
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // for some reason, didFailWithError is called twice so two error popups is appearing
        // just need to show once only for this VC view cycle
        if showedLocationMessage {
            return
        }
        showedLocationMessage = true
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            self.showLocationAccessPopup() // keep nagging to user to allow "always"
            break
        }
    }
    
    func showLocationAccessPopup(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled".localized(),
            message: "In order to be notified about child device usage, please open this app's settings and set location access to 'Always'.".localized(),
            preferredStyle: .alert)
        //In order to be notified about adorable kittens near you, please open
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Enable".localized(), style: .default) { (action) in
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
