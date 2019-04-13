//
//  AppDelegate.swift
//  Plano
//
//  Created by Paing Pyi on 4/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//  Test
//

import UIKit
import Device
import XCGLogger
import RealmSwift
import FacebookCore
import UserNotifications
import SwiftyUserDefaults
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Fabric
import Crashlytics
//import Google
import SwiftyStoreKit
import AppsFlyerLib
import FBSDKCoreKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

let log:     XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.default
    
    return log
}()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppsFlyerTrackerDelegate{

    var window: UIWindow?
    private let GOOGLE_API_KEY = "AIzaSyCHRZav7dZlQ2bIUyrNllU3Cq2aDGCCX1w"
    var passPriceValue = "0.0"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   
        // setup RealmDB
        realmDB()
        
        // setup Logger
        setUpLogger()
        
        // setup for Simulator
        if(Device.type() == .simulator) {
            Defaults[.pushToken] = "iOS"
        }
        
        print("Push token : \(Defaults[.pushToken])")
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKSettings.setAutoLogAppEventsEnabled(true)
        
        // Google
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        GMSPlacesClient.provideAPIKey(GOOGLE_API_KEY)
                
        // disable Screen auto lock
        UIApplication.shared.isIdleTimerDisabled = true
        
        setUpInAppPurchase()
        
        setUpAnalyticsNew()
        
        setUpAppFlyer()
        
        Fabric.with([Crashlytics.self])
        
        log.info("App launch is a Non-Organic install. Media source")
        
//        Defaults[.displayedOnBoard] = false
//        Defaults[.displayedSwitchChildGuide] = false
//        Defaults[.displayedTurnoffChildModeGuide] = false
        
        return true
    }
    
    // MARK: -- Application Cycle

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        log.debug(#function)
        
        UserDefaults.standard.set("1", forKey: "IsAppResigned")
        UserDefaults.standard.synchronize()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        log.debug(#function)
        
        ChildSessionManager.sharedInstance.appEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        log.debug(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        log.debug(#function)
        
        AppsFlyerTracker.shared().trackAppLaunch()
        
        ChildSessionManager.sharedInstance.appEnterForeground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log.debug(#function)
        
        ChildSessionManager.sharedInstance.appIsTerminated()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppURLManager.sharedInstance.handleUrl(url: url)
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        Defaults[.pushToken] = deviceTokenString
    }
    
    // MARK: -- User Notification iOS 10
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        log.debug("Handle push from foreground >>> \(notification.request.identifier)")
        // custom code to handle push while app is in the foreground
        log.debug("\(notification.request.content.userInfo)")
        
        ChildSessionManager.sharedInstance.handleLocalNotification(notification.request.content.categoryIdentifier)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log.debug("Handle push from background or closed >>> \(response.actionIdentifier)")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        log.debug("\(response.notification.request.content.userInfo)")
        
        ChildSessionManager.sharedInstance.handleLocalNotification(response.notification.request.content.categoryIdentifier)

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        log.debug("\(userInfo)")
        
        ParentNotificationsManager.sharedInstance.handleNotification(userInfo: userInfo)
        
    }
    
    // MARK: -- User Notification iOS 9

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        log.debug("handleActionWithIdentifier: completionHandler")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        log.debug("handleActionWithIdentifier: withResponseInfo: completionHandler")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("didReceive notification: \(String(describing: notification.category))")
        
        ChildSessionManager.sharedInstance.handleLocalNotification(notification.category)
    }

    // MARK: -- User Defined
    
    func setUpAnalytics(){
        /*
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
         */
    }
    
    func setUpAnalyticsNew(){
        if let gai = GAI.sharedInstance(){
            gai.tracker(withTrackingId: "UA-104961373-1")
            // Optional: automatically report uncaught exceptions.
            gai.trackUncaughtExceptions = true
            
            // Optional: set Logger to VERBOSE for debug information.
            // Remove before app release.
            gai.logger.logLevel = .verbose;
        }else{
            assert(false, "Google Analytics not configured correctly")
        }
    }
    
    func setUpAppFlyer(){
        AppsFlyerTracker.shared().appsFlyerDevKey = "DjjaxLMZw7ucsLrKy2gVog"
        AppsFlyerTracker.shared().appleAppID = "1261481045"
        AppsFlyerTracker.shared().delegate = self
        AppsFlyerTracker.shared().isDebug = true
    }
    
    func onConversionDataReceived(_ installData: [AnyHashable : Any]!) {
        if let data = installData{
            print("\(data)")
            if let status = data["af_status"] as? String{
                if(status == "Non-organic"){
                    if let sourceID = data["media_source"] , let campaign = data["campaign"]{
                        print("This is a Non-Organic install. Media source: \(sourceID) Campaign: \(campaign)")
                        
                        Defaults[.appFlyerId] = sourceID as? String
                        log.info("This is a Non-Organic install. Media source: \(sourceID) Campaign: \(campaign)")
                    }
                } else {
                    Defaults[.appFlyerId] = ""
                    print("This is an organic install.")
                    
                    log.info("This is an Organic install.")
                }
            }
        }
    }
    
    func onConversionDataRequestFailure(_ error: Error!) {
        if let err = error{
            print(err)
        }
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]!) {
        if let data = attributionData{
            print("\(data)")
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error!) {
        if let err = error{
            print(err)
        }
    }
    
    func setUpInAppPurchase(){
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                print("purchased: \(purchase)")
            }
        }
    }

    func setUpLogger(){
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)
    }

    func registerForNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    log.info("Notifications registered")
                }
            }
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    // Notifications not allowed
                    log.error("Notifications not allowed")
                }
            }
        }
        else {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    

    
    func listFonts() {
        if(Device.type() == .simulator) {
            let fontFamilyNames = UIFont.familyNames
            for familyName in fontFamilyNames {
                //Check the Font names of the Font Family
                let names = UIFont.fontNames(forFamilyName: familyName)
                // Write out the Font Famaily name and the Font's names of the Font Family
                log.verbose("Font == \(familyName) \(names)")
            }
        }
    }
    
    
    func realmDB(){
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 82,
            
            // Set the new schema version automatically.
            //schemaVersion: try! schemaVersionAtURL(Realm.Configuration.defaultConfiguration.fileURL!) + 1,
            
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            //Tell RealM to delete old data whenever migration needed to avoid app crashes after App store update
        }, deleteRealmIfMigrationNeeded: true)
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        
        let realm = try! Realm()
        log.info(realm.configuration.fileURL?.absoluteString)
        WoopraTrackingPage().trackEvent(mainMode:"RealM DB Configuration",pageName:"App Delegate Page",actionTitle:"RealM Configuration/Migration Is Done")
        
    }
    
    
    func callParentShopListVC(){
        let navigat = UINavigationController()
        let vcw = ParentWalletVC()
        navigat.pushViewController(vcw, animated: false)
        self.window!.rootViewController = navigat
        self.window!.makeKeyAndVisible()
    }
}
