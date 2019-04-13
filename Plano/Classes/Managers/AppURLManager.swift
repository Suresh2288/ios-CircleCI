//
//  AppURLManager.swift
//  Plano
//
//  Created by Paing Pyi on 7/20/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults
import RealmSwift

class AppURLManager {
    
    static let sharedInstance = AppURLManager() // Singleton init
    
    static let childSessionTimerIdentifier:String = "CHILD_SESSION_TIMER"
    static let planoVerified:String = "plano://verified"
    static let planoSwitchToParent:String = "planoSwitchToParent"

    func handleUrl(url:URL){
        let urlString = url.absoluteString
        
        if urlString.range(of: AppURLManager.planoVerified) != nil {
         
            var signInVC:SignInVC?
            
            if let nav = UIViewController.root as? UINavigationController {
                let vcs = nav.viewControllers
                for vc in vcs {
                    if vc.isKind(of: SignInVC.self) {
                        signInVC = vc as? SignInVC
                        break
                    }
                }

                if let vc = signInVC {
                    nav.popToViewController(vc, animated: true)
                    vc.perform(#selector(vc.handleAutoLoginAfterSuccessfulVerification), with: nil, afterDelay: 1)
                }else{
                    if let vc = UIStoryboard.SignIn() as? SignInVC {
                        nav.popToRootViewController(animated: false)
                        nav.pushViewController(vc, animated: false)
                        vc.perform(#selector(vc.handleAutoLoginAfterSuccessfulVerification), with: nil, afterDelay: 1)
                    }
                }
            }
        }else if urlString.range(of: AppURLManager.planoSwitchToParent) != nil {
            
            // clear childToken and active=0
            let vm = ChildDashboardViewModel()
            vm.destroyChildSession()
            
            // remove timers and GCD events
            ChildSessionManager.sharedInstance.switchToParentMode()
            
            if let token = getQueryStringParameter(url: urlString, param: "token"){
                let request = UpdateDeviceInfoRequest(accessToken: token)
                APIManager.sharedInstance.updateDeviceInfo(data: request, completed: { (response, b) in
                  
                    if response.isSuccess() {
                        
                        let realm = try! Realm()
                        try! realm.write {
                            if let profile = ProfileData.getProfileObj(){
                                profile.accessToken = token
                            }
                        }
                        
                        // switch View
                        if let vc = UIViewController.top as? _BaseViewController {
                            vc.showParentDashboardLanding()
                        }
                        
                    }else{
                        // force user to logout
                        self.logoutUser()
                    }
                    
                })
            }else{
                // force user to logout
                logoutUser()
            }
        }
    }
    
    func logoutUser(){
        
        // logout user
        ProfileData.clearProfileData()
        
        LanguageManager.sharedInstance.resetLanguageToDefault()
        
        let errorMessage = "User token is invalid.".localized()
        
        // bring to login screen
        if let window = UIApplication.shared.keyWindow {
            let nav = UIStoryboard.AuthNav()
            let vcs = nav.viewControllers
            if vcs.count > 0 {
                if let vc = vcs[0] as? _BaseViewController {
                    vc.perform(#selector(vc.showAlert(_:)), with: errorMessage, afterDelay: 1)
                }
            }
            window.rootViewController = nav
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
