//
//  BaseViewController.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit
import Device
import Foundation
import Localize_Swift
import SkyFloatingLabelTextField
import SlideMenuControllerSwift
import SwiftyUserDefaults

class _BaseViewController: UIViewController, UIGestureRecognizerDelegate {
 
    var parentVC:UIViewController?
    var analyticsScreenName:String?
    var appFlyerScreenName:String?

    fileprivate var duringPushAnimation = false
    
    // MARK: - Premium check timer
    var verifyTimer = VerifyTimer()
    var screenName = ""
    let checkSubscriptionModel = CheckSubscriptionViewModel()
    
    let checkPremiumModel = PremiumViewModel()
    
    var product_idIs = ""
    var receiptDataIs = ""
    //var appdelegate = UIApplication.shared.delegate as! AppDelegate
    var preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let notificationNavName = Notification.Name("NotificationNav")
        NotificationCenter.default.addObserver(self, selector: #selector(goToNotificationNavScreen(notificationObj:)), name: notificationNavName, object: nil)
        
        collectAnalytics()
        collectAppFlyerTrack()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableSwipeBackGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // For getting current screen name
        screenName = self.className
        
        if(Device.type() != .simulator) {
            let bundleID = Bundle.main.bundleIdentifier!
            
            if bundleID == Constants.iAP.production{
                verifySubscription()
            }
        }
        
    }
    
    func verifySubscription(){
                    
        if screenName == "MyFamilyVC" || screenName == "PremiumVC" {
            if Defaults[.verifyTimeCheck] != nil{
                if Date() > Defaults[.verifyTimeCheck]!{
                    print("Subscription check start")
                    checkSubscription()
                    Defaults[.verifyTimeCheck] = Date().add(minutes: Constants.verifyCheckMinute)
                }else{
                    print("Subscription check is on it's way")
                }
            }else{
                print("Subscription check for initial")
                checkSubscription()
                Defaults[.verifyTimeCheck] = Date().add(minutes: Constants.verifyCheckMinute)
            }
        }
        
    }
    
    func checkSubscription(){
        iAPManager.shareInstance.verifySubscription(success: { (receiptInfo) in
            
            print("Subscription Check Completed")
            print("receiptInfo:\(receiptInfo)")
            if self.screenName != "ChildDashboardVC"{
                guard let receipt : String = receiptInfo["latest_receipt"] as! String? else{
                    
                    self.checkSubscriptionModel.receiptData = ""
                    
                    return
                }
                
               self.checkSubscriptionModel.receiptData = receipt

            }
            
        }, failure: { (message) in
            
            print("Verify Subscription Failed : \(message)")
            print(self.screenName)
            /*
            self.showAlert("", "You are signed out from iTunes. In order to continue using plano, please sign into your iTunes account.".localized(), "OK", callBack: {
                
                if self.screenName == "MyFamilyVC" || self.screenName == "CustomiseSettingsVC" || self.screenName == "ChildSettingsVC" || self.screenName == "ChildProgressVC"{
                    self.checkSubscriptionModel.logOut(success: { _ in
                        
                        NotificationsList.clearNotificationData()
                        
                        // bring to login screen
                        let nav = UIStoryboard.AuthNav()
                        
                        if let window = UIApplication.shared.keyWindow {
                            if let vc = nav.childViewControllers.first {
                                window.rootViewController = nav
                                UIView.transition(from: self.view, to: vc.view, duration: 1.0, options: [.transitionCrossDissolve], completion: {
                                    _ in
                                    
                                    // do nothing
                                    
                                })
                            }
                        }
                        
                    }) { (errorMessage) in
                        
                        self.showAlert(errorMessage)
                    }
                }else if self.screenName == "ChildDashboardVC"{
                    self.checkSubscriptionModel.doChildLogOut(success: { _ in
                        
                        NotificationsList.clearNotificationData()
                        
                        // bring to login screen
                        let nav = UIStoryboard.AuthNav()
                        
                        if let window = UIApplication.shared.keyWindow {
                            if let vc = nav.childViewControllers.first {
                                window.rootViewController = nav
                                UIView.transition(from: self.view, to: vc.view, duration: 1.0, options: [.transitionCrossDissolve], completion: {
                                    _ in
                                    
                                    // do nothing
                                    
                                })
                            }
                        }
                        
                    }) { (errorMessage) in
                        
                        self.showAlert(errorMessage)
                    }
                }
                Defaults[.verifyTimeCheck] = Date()
            })
            */
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func enableSwipeBackGesture() {
        guard let gestureRecognizer = self.navigationController?.interactivePopGestureRecognizer else {
            return
        }
        if (self.navigationController?.viewControllers.count)! > 1{
            gestureRecognizer.isEnabled = true
        }else{
            gestureRecognizer.isEnabled = false
            
        }
    }
    
    func collectAnalytics(){
        if let screenName = analyticsScreenName {
            AnalyticsHelper().analyticLogScreen(screen: screenName)
        }
    }
    
    func collectAppFlyerTrack(){
        if let screenName = appFlyerScreenName{
            AppFlyerHelper().trackScreen(screenName: screenName)
        }
    }

    func configFloatingLabel(_ textField:SkyFloatingLabelTextField){
        
        let alignment:NSTextAlignment = .center
        let font = FontBook.Light.of(size: 13)
        let closure = { (text:String) -> String in
            return text
        }
        
        textField.textAlignment = alignment
        textField.titleLabel.textAlignment = alignment
        textField.titleLabel.font = font
        textField.titleFormatter = closure
        textField.titleFadeOutDuration = 0.2
        textField.errorColor = UIColor.red
        textField.selectedTitleColor = Color.Cyan.instance()
        textField.lineHeight = 0
        textField.selectedLineHeight = 0
        textField.textColor = Color.Magenta.instance()
        
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
    }
    
    // MARK: -- Navigation Bar
    
    func customizeNavBar(){
        let navigationTitleFont = FontBook.Bold.of(size: 16)
        let whiteColor = UIColor.white
        self.navigationItem.setLeftBarButton(showBackBtn(), animated: false)
        
        if let nav = navigationController {
            nav.navigationBar.barTintColor = Color.Cyan.instance()
            nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: navigationTitleFont, NSAttributedString.Key.foregroundColor.rawValue: whiteColor])
//            nav.navigationBar.backgroundColor = UIColor.clear
            nav.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            nav.navigationBar.isTranslucent = true
            nav.navigationBar.shadowImage = UIImage()
            
        }
    }
    
    // MARK: -- Navigation Bar [Menu Button] with custom settings
    func setupMenuNavBarWithAttributes(navtitle : String, setStatusBarStyle : UIStatusBarStyle, isTransparent : Bool, tintColor : UIColor, titleColor : UIColor, titleFont : UIFont){
        
        title = navtitle.localized()
        
        UIApplication.shared.statusBarStyle = setStatusBarStyle
        
        guard let nav = self.navigationController else { return }
        
        if isTransparent{
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.isTranslucent = true
        }else{
            nav.navigationBar.backgroundColor = UIColor.clear
            nav.navigationBar.isTranslucent = false
        }
        
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.barTintColor = tintColor
        nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: titleColor,
            NSAttributedString.Key.font.rawValue: titleFont
        ])
        
        navigationItem.setLeftBarButton(showMenuBtn(), animated: false)
    }
    
    // MARK: -- Navigation Bar [Back Button] with custom settings
    func setUpNavBarWithAttributes(navtitle : String, setStatusBarStyle : UIStatusBarStyle, isTransparent : Bool, tintColor : UIColor, titleColor : UIColor, titleFont : UIFont){
        
        title = navtitle.localized()
        
        UIApplication.shared.statusBarStyle = setStatusBarStyle
        
        guard let nav = self.navigationController else { return }
        
        if isTransparent{
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.isTranslucent = true
        }else{
            nav.navigationBar.backgroundColor = UIColor.clear
            
            let image = UIImage(color: Color.Cyan.instance())
            nav.navigationBar.setBackgroundImage(image, for: .default)

        }
        
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.barTintColor = tintColor
        nav.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: titleColor,
            NSAttributedString.Key.font.rawValue: titleFont
        ])
        
        navigationItem.setLeftBarButton(showBackBtn(), animated: false)
    }
    
    func showBackBtn() -> UIBarButtonItem {
        let img : UIImage? = UIImage.init(named: "iconBackBtn")!.withRenderingMode(.alwaysOriginal)
        let btn:UIBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(btnBackClicked))
        
        return btn
    }
    
    func showMenuBtn() -> UIBarButtonItem {
        let img : UIImage? = UIImage.init(named: "iconMenu")!.withRenderingMode(.alwaysOriginal)
        let btn:UIBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(btnMenuClicked))
        btn.imageInsets = UIEdgeInsets.init(top: 2,left: 8,bottom: 0,right: -8) // move image to the right for 8 pixel
        return btn
    }
    
    @objc func btnBackClicked(){
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    @objc func btnMenuClicked(){
        
        if let _ = self.navigationController {
            self.slideMenuController()?.openLeft()
        }
    }
    
    func setupMenuView(vc:_BaseViewController?, nav: UINavigationController){
        
        let menu = UIStoryboard.MenuVC()
        
        // Added some configuration for slide menu
        
        if Device.size() >= .screen7_9Inch{
            SlideMenuOptions.leftViewWidth = UIScreen.main.bounds.width - 200
        }else{
            SlideMenuOptions.leftViewWidth = UIScreen.main.bounds.width - 30
        }
        
        SlideMenuOptions.contentViewScale = 1
        SlideMenuOptions.hideStatusBar = false
        
        let slideMenuController = SlideMenuController(mainViewController: nav, leftMenuViewController: menu)
        slideMenuController.automaticallyAdjustsScrollViewInsets = false
        if let vvcc = vc {
            slideMenuController.delegate = vvcc
        }        
        
//        UIApplication.shared.windows.first?.makeKeyAndVisible()
//        UIApplication.shared.windows.first?.rootViewController = slideMenuController
        
        if let window = UIApplication.shared.keyWindow {
            window.makeKeyAndVisible()
            
            if let vc = nav.children.first {
                window.rootViewController = slideMenuController
                UIView.transition(from: self.view, to: vc.view, duration: 0.6, options: [.transitionFlipFromLeft], completion: {
                    _ in
                    
                })
            }
        }
        
    }
    
    func showParentDashboardLanding(){
        let nav = UIStoryboard.ParentDashboardNav()
        let vc = nav.viewControllers[0] as! MyFamilyVC
        
        vc.alreadyGetRecords = true
        
        setupMenuView(vc: vc, nav: nav)
    }

    func showChildRecordLanding(){
        log.verbose("// show Child List ViewController")
        
        let nav = UIStoryboard.ParentDashboardNav()
        let vc = nav.viewControllers[0] as! MyFamilyVC
        
        vc.childRecordsFound = true
        vc.alreadyGetRecords = true
        
        setupMenuView(vc: vc, nav: nav)
    }
    
    func showParentChildLandingScreen(){
        let introViewModel = IntroViewModel()
        introViewModel.getChildRecord(completed: { (hasChildRecords) in
            if hasChildRecords {
                self.showChildRecordLanding()
            }else{
                self.showParentDashboardLanding()
            }
        })
    }
    
    func flipAnimateViewController(nav:UINavigationController){
        
        if let window = UIApplication.shared.keyWindow {
            if let vc = nav.children.first {
                window.rootViewController = nav
                UIView.transition(from: self.view, to: vc.view, duration: 0.6, options: [.transitionFlipFromLeft], completion: {
                    _ in
                    
                })
            }
        }
    }

    func removeLeftMenuGesture(){
        self.slideMenuController()?.removeLeftGestures()
    }
    
    func addLeftMenuGesture(){
        self.slideMenuController()?.addLeftGestures()
    }
    
    func getMasterDataInBackground(){
        if let profile = ProfileData.getProfileObj() {
            let data = MasterDataRequest(email: profile.email, accessToken: profile.accessToken)
            APIManager.sharedInstance.getMasterData(data: data, completed: { (apiResponseHandler, error) in
                //
            })
        }
    }
    
    @objc func goToNotificationNavScreen(notificationObj : Notification){
        
        if let userInfo = notificationObj.userInfo {
            if userInfo["ScreenName"] as! String == "Progress"{
                if let childID = userInfo["ChildID"] as? String {
                    if Device.size() >= .screen7_9Inch{
                        if let vc = UIStoryboard.ChildProgressiPad() as? ChildProgressVCiPad {
                            vc.childID = Int(childID)!
                            vc.isChildRequestNotifications = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        if let vc = UIStoryboard.ChildProgress() as? ChildProgressVC {
                            vc.childID = Int(childID)!
                            vc.isChildRequestNotifications = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else if userInfo["ScreenName"] as! String == "Premium"{
                if let vc = UIStoryboard.Premium() as? PremiumVC{
                    vc.parentVC = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                if let vc = UIStoryboard.LinkedAccounts() as? LinkedAccountsVC{
                    vc.parentVC = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // Premium invalid alert
    func isPremiumValid(errorCode : Int) -> Bool{
        if errorCode == 120{
            return false
        }else{
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }
}


extension _BaseViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
        print("SlideMenuControllerDelegate: rightDidClose")
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
