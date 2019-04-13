//
//  CheckSubscriptionViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 8/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import SwiftyStoreKit
import StoreKit

class CheckSubscriptionViewModel{
    
    var premiumCode : String?
    var receiptData : String?
    var shareSecret : String?
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func logOut(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = LogOutRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            
            beforeApiCall?()
            
            ParentApiManager.sharedInstance.logOut(data, completed: {[weak self] (apiResponseHandler,error) in
                
                self?.afterApiCall?()
                
                if apiResponseHandler.isSuccess() {
                    
                    // logout user
                    //ProfileData.clearProfileData()
                    
                    LanguageManager.sharedInstance.resetLanguageToDefault()
                    
                    // to double make sure child session is cleared as well
                    ChildSessionManager.sharedInstance.destroyAllSessionsWithoutChildSession()
                    
                    success(apiResponseHandler.message!)
                    
                }else{
                    
                    failure(apiResponseHandler.errorMessage())
                    
                }
            })
        }
    }
    
    func doChildLogOut(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let childProfile = ActiveChildProfile.getProfileObj(){
            
            let data = ChildLogOutRequest()
            data.childID = childProfile.childID
            data.accessToken = Defaults[.childAccessToken]!
            
            beforeApiCall?()
            
            ChildApiManager.sharedInstance.doChildLogOut(data, completed: {[weak self] (apiResponseHandler,error) in
                
                self?.afterApiCall?()
                
                if apiResponseHandler.isSuccess() {
                    
                    // logout user
                    ProfileData.clearProfileData()
                    
                    LanguageManager.sharedInstance.resetLanguageToDefault()
                    
                    // to double make sure child session is cleared as well
                    ChildSessionManager.sharedInstance.destroyAllSessionsWithoutChildSession()
                    
                    success(apiResponseHandler.message!)
                    
                }else{
                    
                    failure(apiResponseHandler.errorMessage())
                    
                }
            })
        }
        
    }
    
    func updatePremium(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            let data = UpdatePremiumRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.appleSubscriptionCode = _BaseViewController().preferences.string(forKey: "productId") ?? ""
            data.appleReceiptPayload = _BaseViewController().preferences.string(forKey: "latest_receipt") ?? ""
            data.languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
            data.country = profile.countryResidence!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                iAPManager.shareInstance.UpdateIOSPremium(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    if apiResponseHandler.isSuccess() {
                        success()
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
}
