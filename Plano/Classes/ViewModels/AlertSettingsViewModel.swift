//
//  AlertSettingsViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class AlertSettingsViewModel{
    
    var alertID : Int?
    var allowPush : Bool?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    
    func getAlertSettings(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = AlertSettingsRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getAlertSettings(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<AlertSettingsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let detail = response.alertSettings{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(AlertSettings.self))
                                    realm.add(detail)
                                }
                                
                            }
                        }
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func updateAlertSettings(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateAlertSettingsRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.alertID = alertID
            data.allowPush = allowPush
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateAlertSettings(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let setting : Results<AlertSettings> = AlertSettings.getSettingByAlertID(alertID: (self?.alertID!)!){
                            
                            let realm = try! Realm()
                            
                            try! realm.write {
                                setting.first?.setValue(self?.allowPush?.toString(), forKeyPath: "AllowPush")
                            }
                        }
                        
                        success(apiResponseHandler.message!)
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
}
