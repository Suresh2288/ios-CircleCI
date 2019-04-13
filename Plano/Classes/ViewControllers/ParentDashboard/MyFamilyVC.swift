//
//  MyFamilyVC.swift
//  Plano
//
//  Created by Thiha Aung on 4/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import PopupDialog
import RealmSwift
import Kingfisher
import PKHUD
import Device
import SwiftDate
import CoreLocation
import SafariServices
import SlideMenuControllerSwift
import ObjectMapper


class MyFamilyVC: _BaseViewController{
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblUserInfo : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblParentPoints : UILabel!

    @IBOutlet weak var childsCollectionView : UICollectionView!
    @IBOutlet weak var childsPageControl : UIPageControl!
    @IBOutlet weak var btnAddChild : UIButton!
    @IBOutlet weak var btnTakeTour : UIButton!
    @IBOutlet weak var imgStartUp : UIImageView!
    @IBOutlet weak var addChildButtonConstraint : NSLayoutConstraint!
    @IBOutlet weak var childsPageControlConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var btnTakeTourConstraint : NSLayoutConstraint!
    @IBOutlet weak var btnAddChildConstraint : NSLayoutConstraint!
    
    @IBOutlet weak var imgPlanoTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPointsSpaceConstaint: NSLayoutConstraint!
    @IBOutlet weak var imgPlanoSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var NonSGParentPointsView: UIView!
    @IBOutlet weak var NonSGPointsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var SGPointsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var RewardsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var SGParentPointsView: UIView!
    @IBOutlet weak var RewardsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var RewardsViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblNonSGPlanoPoints: UILabel!
    @IBOutlet weak var lblPointsTrailingConstraint: NSLayoutConstraint!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var RewardsView: UIView!
    // MARK: - CollectionView Settings
    var collectionMargin : CGFloat = 0.0
    var itemSpacing : CGFloat = 0.0
    var itemHeight : CGFloat = 0.0
    var itemWidth : CGFloat = 0.0
    
    var cellCurrentIndex : Int?
    
    var childProfiles : Results<ChildProfile>!
    var viewModel = MyFamilyViewModel()
    var selectedChildID : Int = 0 {
        didSet {
            viewModel.selectedChildID = selectedChildID
        }
    }
    
    var editProfileGesture : UITapGestureRecognizer!
    let placeholderImage = UIImage(named: "iconAvatar")
    
    // MARK: - Flags
    var childRecordsFound: Bool = false
    var alreadyGetRecords : Bool = false
    var newChildIsAdded: Bool = false
    
    var guide:UIView?
    var shouldShowGuideView = false // Show GuideView after a child is successfully added
    var RewardsPrompt : String = ""
    var IsPaidPremiumUser : Int = 0
    
    // MARK: - LifeCycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupMenuNavBarWithAttributes(navtitle: "Home".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16.0))
        
        setUpLayout()
        
        viewModelCallBack()
        
        if Device.size() == .screen3_5Inch {
            lblUserInfo.font = UIFont(name: lblUserInfo.font.fontName, size: 16)
        }
        
        if let parentProfile = ProfileData.getProfileObj() {
            let wholeStr = "Hello \(parentProfile.firstName).".localized()
            
            let str = NSMutableAttributedString(string: wholeStr)
            
            let r = (wholeStr as NSString).range(of: parentProfile.firstName)
            str.addAttribute(NSAttributedString.Key.font, value: FontBook.Bold.of(size: 28), range: r)
            
            // display in Main queue for UI
            self.lblTitle.attributedText = str
            
            if parentProfile.countryResidence == "SG"{
                SGParentPointsView.isHidden = false
                NonSGParentPointsView.isHidden = true
                RewardsView.isHidden = false
            } else {
                SGParentPointsView.isHidden = true
                NonSGParentPointsView.isHidden = false
                RewardsView.isHidden = true
            }
        }
        
        btnAddChild.isHidden = true
        btnTakeTour.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let parentProfile = ProfileData.getProfileObj() {
            WoopraTrackingPage().profileInfo(name: "\(parentProfile.firstName) \(parentProfile.lastName)", email: parentProfile.email,country: (Locale.current as NSLocale).object(forKey: .countryCode) as! String, city: (parentProfile.city  ?? ""),countryCode: (parentProfile.countryCode ?? ""), mobile: parentProfile.mobile, profileImage: (parentProfile.profileImage ?? ""),deviceType: "iOS",deviceID: parentProfile.accessToken)
            WoopraTrackingPage().trackEvent(mainMode:"Parent Home Page",pageName:"Home Page",actionTitle:"Dashboard")
        }
        
        
        setUpNavigationBar()
        
        viewModel.getChildRecord(completed: { (hasChildRecords) in
            if hasChildRecords {
                self.showChildView()
                
                if self.shouldShowGuideView {
                    self.showGuideAfterSuccessfulAddChild()
                    self.shouldShowGuideView = false
                }
            }else{
                self.showGetStartedAndFeedbackIfRequired()
                self.setUpNoChildView()
            }
            
            // is it first child?
            if self.newChildIsAdded && self.childProfiles.count == 1 {
                
                AnalyticsHelper().analyticLogScreen(screen: "firstchild_registered")
                
                AppFlyerHelper().trackScreen(screenName: "firstchild_registered")
            }
        })
        
        let AppResignStr = UserDefaults.standard.string(forKey: "IsAppResigned")
        
        if(AppResignStr == "1") {
            
            UserDefaults.standard.set("0", forKey: "IsAppResigned")
            UserDefaults.standard.synchronize()
            
            // Register notification
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.registerForNotification()
            }
        }
        
        getPlanoPoints()
        CheckUserStatus()
    }
    
    
    func getPlanoPoints(){
        setUpNavigationBar()
        
        if let parentProfile = ProfileData.getProfileObj() {
            let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentApiManager.sharedInstance.getParentPlanoPoints(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetParentPlanoPointsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            print(response.ParentPlanoPoint)
                            self.lblParentPoints.text = String(response.ParentPlanoPoint) + " pts"
                            self.lblNonSGPlanoPoints.text = String(response.ParentPlanoPoint) + " pts"
                        }
                    }
                })
            }
        }
        
    }
    
    func CheckUserStatus(){
        
        if let parentProfile = ProfileData.getProfileObj() {
            let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentApiManager.sharedInstance.CheckUserStatus(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<CheckUserStatusResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            self.IsPaidPremiumUser = response.IsPaidPremiumUser
                            self.RewardsPrompt = response.NotSubscriberNtucMessage
                        }
                    }
                })
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showAdsViewIfRequired()
        self.StartUpdatingLocation()

    }
    
    func StartUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("No access")
                locationManager.requestAlwaysAuthorization()
            case .restricted, .denied:
                print("No access")
                self.showLocationAccessPopup()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            print("Location services are not enabled")
            self.showLocationAccessPopup()
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - UICollectionViewFlowLayout
    func setUpLayout(){
        
        guard let childProfileCollectionView = childsCollectionView else { return }
        
        //let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if Device.size() == .screen3_5Inch{
            
            childProfileCollectionView.register(UINib(nibName : "ChildProfileCollectionViewCell_3_5Inch", bundle : nil), forCellWithReuseIdentifier: "ChildProfileCollectionViewCell_3_5Inch")
            collectionMargin = 25.0
            itemSpacing = 7.0
            itemHeight = UIScreen.main.bounds.height - 192.0
            childsPageControlConstraint.constant = 20
            
        }else if Device.size() == .screen4Inch{
            
            childProfileCollectionView.register(UINib(nibName : "ChildProfileCollectionViewCell_4Inch", bundle : nil), forCellWithReuseIdentifier: "ChildProfileCollectionViewCell_4Inch")
            collectionMargin = 25.0
            itemSpacing = 7.0
            itemHeight = UIScreen.main.bounds.height - 180.0
            childsPageControlConstraint.constant = 20
            
        }else if Device.size() <= .screen5_8Inch{
            
            childProfileCollectionView.register(UINib(nibName : "ChildProfileCollectionViewCell", bundle : nil), forCellWithReuseIdentifier: "ChildProfileCollectionViewCell")
            
            if Device.size() == .screen5_8Inch{
                itemHeight = UIScreen.main.bounds.height - 252.0
            }else{
                itemHeight = UIScreen.main.bounds.height - 192.0
            }
            
            collectionMargin = 25.0
            itemSpacing = 7.0
            
        }else{
            
            childProfileCollectionView.register(UINib(nibName : "ChildProfileCollectionView_iPadCell", bundle : nil), forCellWithReuseIdentifier: "ChildProfileCollectionView_iPadCell")
            
            itemHeight = UIScreen.main.bounds.height - 312.0
            childsPageControlConstraint.constant = 90
            
            collectionMargin = 85.0
            itemSpacing = 9.0
        }
        
        itemWidth =  UIScreen.main.bounds.width - collectionMargin * 2.0
        
        if Device.size() >= .screen7_9Inch{
            addChildButtonConstraint.constant = itemWidth + 90
        }else{
            addChildButtonConstraint.constant = itemWidth
        }
        
        if Device.size() < .screen7_9Inch {
            imgPlanoTopSpaceConstraint.constant = 10
            imgPlanoSpaceConstraint.constant = 10
            NonSGPointsTopConstraint.constant = 10
            NonSGPointsTopConstraint.constant = 10
            RewardsViewTopConstraint.constant = 5
            RewardsViewWidth.constant = 40
            RewardsViewHeight.constant = 40
            RewardsView.layer.cornerRadius = 20;
            RewardsView.layer.masksToBounds = true;
        } else {
            RewardsView.layer.cornerRadius = RewardsView.frame.size.width/2;
            RewardsView.layer.masksToBounds = true;
        }
        
        childProfileCollectionView.showsHorizontalScrollIndicator = false
        childProfileCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        childsPageControl.isUserInteractionEnabled = false
        
    }
    
    // Show if there is no child profile created
    func setUpNoChildView(){
        
        setupMenuNavBarWithAttributes(navtitle: "Home".localized(), setStatusBarStyle: .lightContent, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .white, titleFont: FontBook.Bold.of(size: 16.0))
        
        imgStartUp.isHidden = false
        lblTitle.isHidden = false
        lblUserInfo.isHidden = false
        btnTakeTour.isHidden = false
        btnAddChild.isHidden = false
        
        childsPageControl.hidesForSinglePage = true
        childsCollectionView.isHidden = true
        
        btnAddChild.setTitle("Add child".localized(), for: .normal)
        btnTakeTour.setTitle("Take the tour".localized(), for: .normal)
        
        btnAddChildConstraint.constant = 87.0
        btnTakeTourConstraint.constant = 22.0
    }
    
    func showChildView(){
        
        setupMenuNavBarWithAttributes(navtitle: "My family".localized(), setStatusBarStyle: .default, isTransparent: true, tintColor: Color.Cyan.instance(), titleColor: .black, titleFont: FontBook.Bold.of(size: 16.0))
        
        btnTakeTour.isHidden = true
        btnAddChild.isHidden = false
        
        imgStartUp.isHidden = true
        lblTitle.isHidden = true
        lblUserInfo.isHidden = true
        
        childProfiles = ChildProfile.getChildProfiles()
        
        childsCollectionView.reloadData()
        childsCollectionView.isHidden = false
        
        childsPageControl.hidesForSinglePage = true
        childsPageControl.numberOfPages = childProfiles.count
        
        if childProfiles.count > 0{
            btnAddChild.setTitle("Add another child".localized(), for: .normal)
        }else{
            btnAddChild.setTitle("Add child".localized(), for: .normal)
        }
        
        btnAddChildConstraint.constant = 22.0
        
    }
    
    func showAdsViewIfRequired(){
        
        // show Ads if we have ads obj
        if let _ = try! Realm().objects(SplashAdvertising.self).first {
            if let lastDate = Defaults[.lastAdsShownAt] {
                let today = Date()
                if !lastDate.isInSameDayOf(date: today) {
                    let vc = UIStoryboard.PopupVCByName(AdsVC.className)
                    self.present(vc, animated: true, completion: nil)
                }
            }else{
                let vc = UIStoryboard.PopupVCByName(AdsVC.className)
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func showGetStartedAndFeedbackIfRequired(){
        if Defaults[.displayedGetStarted] == false {
            self.welcomeDialog()
        }
        if let lastFeedbackShownAt = Defaults[.lastFeedbackShownAt] {
            if Defaults[.stopDisplayFeedback] == false && !lastFeedbackShownAt.isInSameDayOf(date: Date()) { // is it yesterday?
                self.rateOurApp()
            }
        }else{
            Defaults[.lastFeedbackShownAt] = Date() // this must be the 1st time and set current date so it will be displayed next time
        }
    }
    
    // Show if there was childs included
    func childRecordsFound(animated : Bool = true) {
        
        if alreadyGetRecords{
            if !childRecordsFound{
                setUpNoChildView()
            }else{
                showChildView()
            }
            // This is for managing data which come from start up
            alreadyGetRecords = false
        }else{
            viewModel.getChildRecord(completed: { (hasChildRecords) in
                if hasChildRecords {
                    self.showChildView()
                }else{
                    self.setUpNoChildView()
                }
            })
        }
    }
    
    
    
    // MARK: - NavigationBar
    func setUpNavigationBar(){
        
        title = "My Family".localized()
        
        //        navigationController?.navigationBar.barStyle = .black
        UIApplication.shared.statusBarStyle = .default
        
        guard let pav_navigationController = self.navigationController else { return }
        
        pav_navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        pav_navigationController.navigationBar.shadowImage = UIImage()
        pav_navigationController.navigationBar.isTranslucent = true
        pav_navigationController.navigationBar.tintColor = UIColor(hexString: Color.FlatPurple.rawValue)
        pav_navigationController.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: UIColor.black,
            NSAttributedString.Key.font.rawValue: UIFont(name: FontBook.Bold.rawValue, size: 17)!
        ])
        
        navigationItem.leftBarButtonItem = showMenuBtn()
        
    }
    
    // MARK: - CallBack
    func viewModelCallBack() {
        viewModel.beforeApiCall = {
            HUD.show(.systemActivity)
        }
        
        viewModel.afterApiCall = {
            HUD.hide()
        }
        
        viewModel.openInSafari = {[weak self](url) in
            self?.showPlanoProfilePopup(url: url)
        }
    }
    
    func gotoNextScreen() {
        
    }
    
    // MARK: - Dialogs
    func welcomeDialog(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Welcome to plano!".localized()
        let message = "You are just one step away from realising the health benefits and family rewards plano has to offer. Click ‘Add Child’ to set up their profile.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = CancelButton(title: "GET STARTED".localized()) {
            Defaults[.displayedGetStarted] = true
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
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    func rateOurApp(animated: Bool = true) {
        
        // Prepare the popup
        let title = "Rate our app".localized()
        let message = "Is our app helping to manage your child's use of smart devices?\nPlease take a moment to rate us or send us a feedback.".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "FEEDBACK".localized()) {
            Defaults[.stopDisplayFeedback] = true
            if let vc = UIStoryboard.Feedback() as? FeedbackVC {
                vc.fromMenu = false
                if let nav = self.navigationController {
                    nav.pushViewController(vc, animated: true)
                }
            }
        }
        let buttonTwo = DefaultButton(title: "RATE APP".localized()) {
            // TODO: Open RateApp
            Defaults[.stopDisplayFeedback] = true
        }
        let buttonThree = CancelButton(title: "LATER".localized()) {
            Defaults[.lastFeedbackShownAt] = Date()
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
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo, buttonThree])
        self.SpamPopup()
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    func SpamPopup(){
        let when = DispatchTime.now() + 604800 // 7 Days
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            self.rateOurApp()
        }
    }
    // MARK: - User Action
    
    // Edit Profile
    @objc func editChildProfileClicked(_ sender: UITapGestureRecognizer) {
        
        print("Editing Come in")
        
        let tapLocation = sender.location(in: childsCollectionView)
        let indexPath : IndexPath = childsCollectionView.indexPathForItem(at: tapLocation)!
        
        let cid = childProfiles[indexPath.row].childID
        
        let childProfile = ChildProfile.getChildProfileById(childId: cid)
        
        if Device.size() >= .screen7_9Inch {
            if let vc = UIStoryboard.AddChild() as? AddChildVCiPad {
                WoopraTrackingPage().trackEvent(mainMode:"Parent Edit Child Page",pageName:"Edit Child Page",actionTitle:"Dashboard")
                vc.isInEditMode = true
                vc.childProfile = childProfile
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = UIStoryboard.AddChild() as? AddChildVC {
                WoopraTrackingPage().trackEvent(mainMode:"Parent Edit Child Page",pageName:"Edit Child Page",actionTitle:"Dashboard")
                vc.isInEditMode = true
                vc.childProfile = childProfile
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // Child Setting
    @objc func parentShopClicked(_ sender: UIButton) {
        if let vc = UIStoryboard.Wallet() as? ParentWalletVC{
            vc.parentVC = self
            vc.comeFromDashboard = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Added Child ID to transfer the data
    @objc func childSettingsClicked(_ sender: UIButton) {
        selectedChildID = Int(childProfiles[sender.tag].childID)!
        
        if Device.size() >= .screen7_9Inch{
            if let vc = UIStoryboard.ChildSettingsiPad() as? ChildSettingsVCiPad {
                vc.parentVC = self
                vc.childID = selectedChildID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if let vc = UIStoryboard.ChildSettings() as? ChildSettingsVC {
                vc.parentVC = self
                vc.childID = selectedChildID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // Child Progress Clicked
    @objc func childProgressClicked(_ sender: UIButton) {
        selectedChildID = Int(childProfiles[sender.tag].childID)!
        print("selectedChildID : \(selectedChildID)")
        
        if Device.size() >= .screen7_9Inch{
            if let vc = UIStoryboard.ChildProgressiPad() as? ChildProgressVCiPad {
                vc.parentVC = self
                vc.childID = selectedChildID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if let vc = UIStoryboard.ChildProgress() as? ChildProgressVC {
                vc.parentVC = self
                vc.childID = selectedChildID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @objc func switchChildModeClicked(_ sender: UIButton) {
        
        if Device.isSimulator() {
            
            // Location Service - On > ask for GPS > install Profile > switch to Childmode
            // Location Service - Off > install Profile > switch to Childmode
            cellCurrentIndex = sender.tag
            self.selectedChildID = Int(self.childProfiles[sender.tag].childID)!
            
            // Get from API to know Location is On/Off
            viewModel.getCustomiseSettingsSummary(childID: self.selectedChildID, success: { 
                
                guard let settingSummaryObj : CustomiseSettingsSummary = CustomiseSettingsSummary.getCustomiseSettingSummaryObj() else{
                    
                    self.showAlert("Missing records. Please try again!")
                    return
                }
                
                if settingSummaryObj.isLocationOptionActive() {
                    
                    // ask for GPS
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedAlways:
                        
                        self.switchToChildMode(sender)
                        break
                    default:
                        
                        // if not Always, ask for Location permission
                        self.initLocationService()
                        break
                    }
                    
                }else{
                    self.switchToChildMode(sender)
                }
                
            }, failure: { (message) in
                self.showAlert(message)
            })
            
        }else{
            // Is PushNoti Enabled or not?
            if !UIApplication.shared.isPushNotificationEnabled() {
                
                // Force user to change PushNoti setting in settings
                self.showAlert("", "This app uses push notifications to help children build better device habits. Please turn on notifications in settings.".localized(), "CANCEL".localized(), "OPEN SETTINGS".localized(), callBackOne: {
                }, callBackTwo: {
                    UIApplication.shared.openAppSettings()
                })
                
            }else if Defaults[.pushToken].isEmpty { // Is Push Token Empty or not?
                
                // Force user to change PushNoti setting in settings
                self.showAlert("", "We cannot access Push Notifications. plano® requires this to ensure your child receives alerts to build better device habits. Please turn on notifications in settings then restart the app.".localized(), "CANCEL".localized(), "OPEN SETTINGS".localized(), callBackOne: {
                }, callBackTwo: {
                    UIApplication.shared.openAppSettings()
                })
                
            }else{
                
                // PushNoti is working fine. So just login
                // Location Service - On > ask for GPS > install Profile > switch to Childmode
                // Location Service - Off > install Profile > switch to Childmode
                self.cellCurrentIndex = sender.tag
                self.selectedChildID = Int(self.childProfiles[sender.tag].childID)!
                
                // Get from API to know Location is On/Off
                self.viewModel.getCustomiseSettingsSummary(childID: self.selectedChildID, success: { 
                    
                    guard let settingSummaryObj : CustomiseSettingsSummary = CustomiseSettingsSummary.getCustomiseSettingSummaryObj() else{
                        
                        // if location info is failed to get,
                        
                        self.switchToChildMode(sender)
                        return
                    }
                    
                    if settingSummaryObj.isLocationOptionActive() {
                        
                        // ask for GPS
                        switch CLLocationManager.authorizationStatus() {
                        case .authorizedAlways:
                            
                            self.switchToChildMode(sender)
                            break
                        default:
                            
                            // if not Always, ask for Location permission
                            self.initLocationService()
                            break
                        }
                        
                    }else{
                        
                        self.switchToChildMode(sender)
                    }
                    
                }, failure: { (message) in
                    self.showAlert(message)
                })
            }
        }
        
    }
    
    func initLocationService(){
        // clear locationManager
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // this will trigger "didChangeAuthorization" if no authorization is made before
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // this is a quite nice function
        // it will trigger to following either of two methods "didUpdateLocations" or "didFailWithError"
        locationManager.requestLocation()
        
        HUD.show(.systemActivity)
    }
    
    func switchToChildMode(_ sender: UIButton){
        
        cellCurrentIndex = sender.tag
        
        self.selectedChildID = Int(self.childProfiles[sender.tag].childID)!
        // Are you sure you want to set the device to child mode?
        // Prepare the popup
        let title = "Set device to child mode".localized()
        let message = "Are you sure you want to set the device to child mode?".localized()
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK".localized()) {
            WoopraTrackingPage().trackEvent(mainMode:"Parent Home Page",pageName:"Home Page",actionTitle:"Switching Parent mode to child mode")
            self.enableChildMode(sender: sender)
        }
        let buttonTwo = DefaultButton(title: "CANCEL".localized()) {
            
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
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func enableChildMode(sender : UIButton){
        
        viewModel.switchToChildMode(completed: {[weak self] (success) in
            if(success){
                
//                                UIView.transition(with: sender, duration: 0.5, options: .curveEaseInOut, animations: {
//
//                                    if Device.size() == .screen3_5Inch{
//                                        sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 150, bottom: 2, right: 2)
//                                    }else{
//                                        sender.imageEdgeInsets = UIEdgeInsets(top: 2, left: 161, bottom: 2, right: 2)
//                                    }
//                                    sender.setTitle("", for: .normal)
//                                    sender.layoutIfNeeded()
//                                }, completion: { (Bool) in
//                                    let nav = UIStoryboard.ChildDashboardNav()
//                                    self.flipAnimateViewController(nav: nav)
//                                })
                
                sender.isSelected = true
                
                self?.perform(#selector(self?.switchToChildModeNav), with: nil, afterDelay: 0.8)
                
            }
            }, failure: { (erorrMessage,errorCode) in
                
                if (errorCode == 128) {
                    self.showAlert("", erorrMessage, "RESET".localized(), "DISMISS".localized(), callBackOne: {
                        print("RESET")
                        self.ResetChildModePrompt()
                    }, callBackTwo: {
                        print("DISMISS")
                    })
                } else {
                    self.showAlert(erorrMessage)
                }
                
        })
        
    }
    
    func ResetChildModePrompt() {
        if let parentProfile = ProfileData.getProfileObj() {
            let request = ResetChildModeRequest(email: parentProfile.email, accessToken: parentProfile.accessToken, childID: String(selectedChildID))
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentApiManager.sharedInstance.ResetChildModePrompt(request, completed: { (apiResponseHandler, error) in
                    
                    if apiResponseHandler.isSuccess() {
                        self.showAlert(apiResponseHandler.message!)
                    } else {
                        self.showAlert(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    @IBAction func btnAddChildClicked(_ sender: Any) {
        WoopraTrackingPage().trackEvent(mainMode:"Parent Add Child Page",pageName:"Add Child Page",actionTitle:"Adding New Child")
        if Device.isSimulator() {
            if let vc = UIStoryboard.AddChild() as? _BaseViewController {
                vc.parentVC = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if let vc = UIStoryboard.AddChild() as? _BaseViewController {
                vc.parentVC = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func btnTakeTourClicked(_ sender: Any) {
        let vc = UIStoryboard.TakeATour()
        present(vc, animated: true, completion: nil)
    }
    
    @objc func switchToChildModeNav(){
        let nav = UIStoryboard.ChildDashboardNav()
        self.flipAnimateViewController(nav: nav)
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
    
    @IBAction func btnRewardsClicked(_ sender: Any) {
        
        //if IsPaidPremiumUser == 1 {
            if let parentProfile = ProfileData.getProfileObj() {
                let request = GetParentPlanoPointsRequest(email: parentProfile.email, accessToken: parentProfile.accessToken)
                
                if ReachabilityUtil.shareInstance.isOnline(){
                    
                    ParentApiManager.sharedInstance.CheckNtucUserNric(request, completed: { (apiResponseHandler, error) in
                        
                        if apiResponseHandler.isSuccess() {
                            
                            if let response = Mapper<CheckNtucUserNricResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                                
                                if (Int(response.IsNtucUserNricExist) == 1) {
                                    if let vc = UIStoryboard.RewardsView() as? RewardsViewVC {
                                        vc.parentVC = self
                                        vc.isFromMainView = true
                                        vc.AvailablePoints = String(response.NtucLinkpointsCredit)
                                        vc.NtucPlusUrl = response.NtucPlusUrl
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                } else {
                                    if let vc = UIStoryboard.ParentRewards() as? ParentRewardsVC {
                                        vc.parentVC = self
                                        vc.AvailablePoints = String(response.NtucLinkpointsCredit)
                                        vc.NtucPlusUrl = response.NtucPlusUrl
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        } else {
                            self.showAlert(apiResponseHandler.errorMessage())
                        }
                    })
                }
            }
//        } else {
//            self.showAlert(RewardsPrompt)
//        }
    }
}



// MARK: - UICollectionView

extension MyFamilyVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if childProfiles != nil{
            return childProfiles.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let childProfile = childProfiles[indexPath.row]
        
        if Device.size() == .screen3_5Inch{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell_3_5Inch", for: indexPath) as! ChildProfileCollectionViewCell_3_5Inch
            
            cell.lblChildName.text = childProfile.firstName.localized() + " " + childProfile.lastName.localized()
            cell.lblChildName.font = UIFont(name: FontBook.ExtraBold.rawValue, size: 18)
            
            //.forceRefresh should use because of 3 reusable cell shown at first
            cell.imgChildProfile.kf.setImage(with: URL(string: childProfile.profileImage), placeholder: placeholderImage,options: [.forceRefresh])
            editProfileGesture = UITapGestureRecognizer(target: self, action: #selector(MyFamilyVC.editChildProfileClicked(_:)))
            cell.imgChildProfile.addGestureRecognizer(editProfileGesture)
            
            cell.btnChildMode.tag = indexPath.row
            //            cell.btnChildMode.setTitle("Tap to start Child mode".localized(), for: .normal)
            cell.btnChildMode.addTarget(self, action: #selector(MyFamilyVC.switchChildModeClicked(_:)), for: .touchUpInside)
            
            cell.btnSettings.tag = indexPath.row
            cell.lblSettings.text = "Settings".localized()
            cell.btnSettings.addTarget(self, action: #selector(MyFamilyVC.childSettingsClicked(_:)), for: .touchUpInside)
            
            cell.btnChildProgress.tag = indexPath.row
            cell.lblChildProgress.text = "Progress".localized()
            cell.btnChildProgress.addTarget(self, action: #selector(MyFamilyVC.childProgressClicked(_:)), for: .touchUpInside)
            
            //if ProfileData.getProfileObj()?.countryResidence == "SG"{
                cell.stk_PlanoShop_Outlet.isHidden = false
                cell.btnShop.isHidden = false
                cell.lblShop.isHidden = false
//            }else{
//                cell.btnShop.isHidden = true
//                cell.lblShop.isHidden = true
//                cell.stk_PlanoShop_Outlet.isHidden = true
//            }
            cell.btnShop.tag = indexPath.row
            cell.lblShop.text = "Shop".localized()
            cell.btnShop.addTarget(self, action: #selector(MyFamilyVC.parentShopClicked(_:)), for: .touchUpInside)
            
            return cell
            
        }else if Device.size() == .screen4Inch{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell_4Inch", for: indexPath) as! ChildProfileCollectionViewCell_4Inch
            
            cell.lblChildName.text = childProfile.firstName.localized() + " " + childProfile.lastName.localized()
            cell.lblChildName.font = UIFont(name: FontBook.ExtraBold.rawValue, size: 18)
            
            //.forceRefresh should use because of 3 reusable cell shown at first
            cell.imgChildProfile.kf.setImage(with: URL(string: childProfile.profileImage), placeholder: placeholderImage,options: [.forceRefresh])
            editProfileGesture = UITapGestureRecognizer(target: self, action: #selector(MyFamilyVC.editChildProfileClicked(_:)))
            cell.imgChildProfile.addGestureRecognizer(editProfileGesture)
            
            cell.btnChildMode.tag = indexPath.row
            //            cell.btnChildMode.setTitle("Tap to start Child mode".localized(), for: .normal)
            cell.btnChildMode.addTarget(self, action: #selector(MyFamilyVC.switchChildModeClicked(_:)), for: .touchUpInside)
            
            cell.btnSettings.tag = indexPath.row
            cell.lblSettings.text = "Settings".localized()
            cell.btnSettings.addTarget(self, action: #selector(MyFamilyVC.childSettingsClicked(_:)), for: .touchUpInside)
            
            cell.btnChildProgress.tag = indexPath.row
            cell.lblChildProgress.text = "Progress".localized()
            cell.btnChildProgress.addTarget(self, action: #selector(MyFamilyVC.childProgressClicked(_:)), for: .touchUpInside)
            //if ProfileData.getProfileObj()?.countryResidence == "SG"{
                cell.stk_PlanoShop_Outlet.isHidden = false
                cell.btnShop.isHidden = false
                cell.lblShop.isHidden = false
//            }else{
//                cell.btnShop.isHidden = true
//                cell.lblShop.isHidden = true
//                cell.stk_PlanoShop_Outlet.isHidden = true
//            }
            cell.btnShop.tag = indexPath.row
            cell.lblShop.text = "Shop".localized()
            cell.btnShop.addTarget(self, action: #selector(MyFamilyVC.parentShopClicked(_:)), for: .touchUpInside)
            
            return cell
            
        }else if Device.size() <= .screen5_8Inch{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell", for: indexPath) as! ChildProfileCollectionViewCell
            
            cell.lblChildName.text = childProfile.firstName.localized() + " " + childProfile.lastName.localized()
            cell.lblChildName.font = UIFont(name: FontBook.ExtraBold.rawValue, size: 21)
            
            //.forceRefresh should use because of 3 reusable cell shown at first
            cell.imgChildProfile.kf.setImage(with: URL(string: childProfile.profileImage), placeholder: placeholderImage,options: [.forceRefresh])
            editProfileGesture = UITapGestureRecognizer(target: self, action: #selector(MyFamilyVC.editChildProfileClicked(_:)))
            cell.imgChildProfile.addGestureRecognizer(editProfileGesture)
            
            cell.btnChildMode.tag = indexPath.row
            //            cell.btnChildMode.setTitle("Tap to start Child mode".localized(), for: .normal)
            cell.btnChildMode.addTarget(self, action: #selector(MyFamilyVC.switchChildModeClicked(_:)), for: .touchUpInside)
            
            cell.btnSettings.tag = indexPath.row
            cell.lblSettings.text = "Settings".localized()
            cell.btnSettings.addTarget(self, action: #selector(MyFamilyVC.childSettingsClicked(_:)), for: .touchUpInside)
            
            cell.btnChildProgress.tag = indexPath.row
            cell.lblChildProgress.text = "Progress".localized()
            cell.btnChildProgress.addTarget(self, action: #selector(MyFamilyVC.childProgressClicked(_:)), for: .touchUpInside)
            //if ProfileData.getProfileObj()?.countryResidence == "SG"{
                cell.stk_PlanoShop_Outlet.isHidden = false
                cell.btnShop.isHidden = false
                cell.lblShop.isHidden = false
//            }else{
//                cell.btnShop.isHidden = true
//                cell.lblShop.isHidden = true
//                cell.stk_PlanoShop_Outlet.isHidden = true
//            }
            cell.btnShop.tag = indexPath.row
            cell.lblShop.text = "Shop".localized()
            cell.btnShop.addTarget(self, action: #selector(MyFamilyVC.parentShopClicked(_:)), for: .touchUpInside)
            
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionView_iPadCell", for: indexPath) as! ChildProfileCollectionView_iPadCell
            
            cell.lblChildName.text = childProfile.firstName.localized() + " " + childProfile.lastName.localized()
            cell.lblChildName.font = UIFont(name: FontBook.Bold.rawValue, size: 25)
            
            //.forceRefresh should use because of 3 reusable cell shown at first
            cell.imgChildProfile.kf.setImage(with: URL(string: childProfile.profileImage), placeholder: placeholderImage,options: [.forceRefresh])
            editProfileGesture = UITapGestureRecognizer(target: self, action: #selector(MyFamilyVC.editChildProfileClicked(_:)))
            cell.imgChildProfile.addGestureRecognizer(editProfileGesture)
            
            cell.btnChildMode.tag = indexPath.row
            //            cell.btnChildMode.setTitle("Tap to start Child mode".localized(), for: .normal)
            cell.btnChildMode.addTarget(self, action: #selector(MyFamilyVC.switchChildModeClicked(_:)), for: .touchUpInside)
            
            cell.btnSettings.tag = indexPath.row
            cell.lblSettings.text = "Settings".localized()
            cell.btnSettings.addTarget(self, action: #selector(MyFamilyVC.childSettingsClicked(_:)), for: .touchUpInside)
            
            cell.btnChildProgress.tag = indexPath.row
            cell.lblChildProgress.text = "Progress".localized()
            cell.btnChildProgress.addTarget(self, action: #selector(MyFamilyVC.childProgressClicked(_:)), for: .touchUpInside)
            //if ProfileData.getProfileObj()?.countryResidence == "SG"{
                cell.stk_PlanoShop_Outlet.isHidden = false
                cell.btnShop.isHidden = false
                cell.lblShop.isHidden = false
//            }else{
//                cell.btnShop.isHidden = true
//                cell.lblShop.isHidden = true
//                cell.stk_PlanoShop_Outlet.isHidden = true
//            }
            cell.btnShop.tag = indexPath.row
            cell.lblShop.text = "Shop".localized()
            cell.btnShop.addTarget(self, action: #selector(MyFamilyVC.parentShopClicked(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // Parent Dashboard Layout Management
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionMargin, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionMargin, height: 0)
    }
    
    // Kingfisher
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if Device.size() == .screen3_5Inch{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell_3_5Inch", for: indexPath) as! ChildProfileCollectionViewCell_3_5Inch
            
            cell.imgChildProfile.kf.cancelDownloadTask()
        }else if Device.size() == .screen4Inch{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell_4Inch", for: indexPath) as! ChildProfileCollectionViewCell_4Inch
            
            cell.imgChildProfile.kf.cancelDownloadTask()
            
        }else if Device.size() <= .screen5_8Inch{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionViewCell", for: indexPath) as! ChildProfileCollectionViewCell
            
            cell.imgChildProfile.kf.cancelDownloadTask()
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChildProfileCollectionView_iPadCell", for: indexPath) as! ChildProfileCollectionView_iPadCell
            
            cell.imgChildProfile.kf.cancelDownloadTask()
        }
    }
    
}

extension MyFamilyVC : UIScrollViewDelegate{
    
    // This was for calculating pagecontrol current page
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float(itemWidth + itemSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(childsCollectionView!.contentSize.width  )
        var newPage = Float(self.childsPageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.childsPageControl.currentPage + 1 : self.childsPageControl.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        
        self.childsPageControl.currentPage = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
    
    
    /////
    
    func showChildProfileCreatedPopupIfRequired(){
        if let d = Defaults[.recentlyAddedChildTimestamp], let _ = Defaults[.recentlyAddedChildID] {
            if d+5.minutes < Date() { // 5 minute past
                userCreatedSuccessfullyReminder()
            }
        }
    }
    
    func userCreatedSuccessfully() {
        scrollToLastChild()
        shouldShowGuideView = true
    }
    
    func userCreatedSuccessfullyReminder() {
        // Create the dialog
        let popup = prepareCreatedSuccessfullyPopup(title:"Customise".localized(), message:"You can now customise settings for your child.".localized(), animated: true)
        self.present(popup, animated: true, completion: nil)
    }
    
    func prepareCreatedSuccessfullyPopup(title:String, message:String, animated: Bool = true) -> PopupDialog {
        
        // Prepare the popup
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "Customize Now".localized()) {
            // change to desired number of seconds (in this case 5 seconds)
            if let vc = UIStoryboard.ChildSettings() as? ChildSettingsVC {
                vc.parentVC = self
                if let cid = Defaults[.recentlyAddedChildID] {
                    vc.childID = cid
                    vc.shouldOpenRefineSetting = true
                }
                
                // Slide Menu View Controller
                if let svc = UIViewController.topViewController() as? SlideMenuController {
                    
                    // Parent Navi > MyFamilyVC
                    if let topvc = UIViewController.topViewController(from: svc.mainViewController) as? _BaseViewController {
                        topvc.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            // clear it
            Defaults[.recentlyAddedChildID] = nil
        }
        
        let buttonTwo = DefaultButton(title: "Use plano Default Settings".localized()) {
            
            if let vc = UIStoryboard.ChildSettings() as? ChildSettingsVC {
                vc.parentVC = self
                if let cid = Defaults[.recentlyAddedChildID] {
                    vc.childID = cid
                }
                
                // Slide Menu View Controller
                if let svc = UIViewController.topViewController() as? SlideMenuController {
                    
                    // Parent Navi > MyFamilyVC
                    if let topvc = UIViewController.topViewController(from: svc.mainViewController) as? _BaseViewController {
                        topvc.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            Defaults[.recentlyAddedChildID] = nil
        }
        
        let buttonThree = DefaultButton(title: "Skip".localized()) {
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
        buttonTwo.setTitleColor(Color.Cyan.instance(), for: .normal)
        buttonThree.setTitleColor(Color.Cyan.instance(), for: .normal)
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonThree])
        
        return popup
    }
    
    func scrollToLastChild(){
        if childProfiles != nil {
            let index = max(0, childProfiles.count-1)
            childsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            childsPageControl.currentPage = index
        }
    }
    
    func showGuideAfterSuccessfulAddChild(){
        if !Defaults[.displayedSwitchChildGuide] && childProfiles.count > 0 {
            
            scrollToLastChild()
            
            perform(#selector(showGuide), with: nil, afterDelay: 0.4)
            
            Defaults[.displayedSwitchChildGuide] = true
        }
    }
    
    @objc func showGuide(){
        self.guide = initGuide()
        if let guide = self.guide {
            guide.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(guide)
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                guide.alpha = 1
            }, completion: nil)
        }
    }
    
    func initGuide() -> UIView {
        let viewHolder = UIView(frame: self.view.bounds)
        let bg = UIView(frame: viewHolder.bounds)
        bg.backgroundColor = UIColor.black
        bg.alpha = 0.8
        viewHolder.addSubview(bg)
        
        let guideImage = UIImageView(image: UIImage(named: "toggleGuide"))
        viewHolder.addSubview(guideImage)
        
        // setting `center` will make easier to adjust the x position without doing much
        var imageSize = CGSize(width: 215, height: 190)
        
        if(Device.size() <= .screen3_5Inch) {
            imageSize = CGSize(width: 165, height: 145)
        }
        
        guideImage.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        guideImage.center = viewHolder.center
        
        // find btnChildMode in current cell index
        let index = childProfiles.count-1
        
        let c = childsCollectionView.cellForItem(at: IndexPath(item: index, section: 0))
        if let cell = c as? BaseChildProfileCollectionViewCell {
            
            // take the position relative to self.view to adjust y position of guide image
            let frame = self.view.convert(cell.btnChildMode.frame, from: cell.btnChildMode.superview)
            guideImage.frame = CGRect(x: guideImage.frame.origin.x, y: frame.origin.y, width: imageSize.width, height: imageSize.height)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissGuide(gesture:)))
        viewHolder.addGestureRecognizer(tap)
        
        return viewHolder
    }
    
    @objc func dismissGuide(gesture:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.guide?.alpha = 0
        }) { (complete) in
            self.guide?.removeFromSuperview()
        }
    }
}

// MARK: - CLLocation Delegate
extension MyFamilyVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        HUD.hide()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied: // authorizedAlways authorizedWhenInUse
            print("Authorization changed")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        HUD.hide()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            self.showLocationAccessPopup() // keep nagging to user to allow "always"
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        HUD.hide()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            //self.showLocationAccessPopup() // keep nagging to user to allow "always"
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
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
