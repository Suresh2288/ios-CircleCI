//
//  UIApplication.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension UIApplication {
    func openAppSettings() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)! as URL)
        }
    }
    
    func isPushNotificationEnabled() -> Bool {
        
        guard let settings = UIApplication.shared.currentUserNotificationSettings
            else {
                return false
        }
        
        return UIApplication.shared.isRegisteredForRemoteNotifications
            && !settings.types.isEmpty
    }
    
    //This Method is added newly to check whether Push notification is enabled or not in Device settings
    //Because UIApplication.shared.currentUserNotificationSettings code is deprecated in iOS 10.0
    func checkPushNotification(checkNotificationStatus isEnable : ((Bool)->())? = nil){
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                
                switch setttings.authorizationStatus{
                case .authorized:
                    
                    print("enabled notification setting")
                    isEnable?(true)
                case .denied:
                    
                    print("setting has been disabled")
                    isEnable?(false)
                case .notDetermined:
                    
                    print("something vital went wrong here")
                    isEnable?(false)
                default: break
                }
            }
        } else {
            
            let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
            if isNotificationEnabled == true{
                
                print("enabled notification setting")
                isEnable?(true)
                
            }else{
                
                print("setting has been disabled")
                isEnable?(false)
            }
        }
    }
}





// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
