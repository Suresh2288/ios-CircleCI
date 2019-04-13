//
//  MenuViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class MenuViewModel{
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func logOut(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = LogOutRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.logOut(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        // logout user
                        
                        LanguageManager.sharedInstance.resetLanguageToDefault()
                        
                        // to double make sure child session is cleared as well
                        ChildSessionManager.sharedInstance.destroyAllSessionsWithoutChildSession()
                        
                        success(apiResponseHandler.message!)
                        WoopraTrackingPage().trackEvent(mainMode:"Parent Logout Page",pageName:"Logout Page",actionTitle:"User Logged Out")

                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func getNotifications(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj(){
            
            let data = GetNotificationsRequest(email: profile.email, accessToken: profile.accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getNotifications(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetNotificationsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let notifications = response.notificationsList{
                                
                                let realm = try! Realm()
                                
                                if NotificationsList.getNotificationsList().count == 0{
                                    try! realm.write {
                                        realm.add(notifications, update : true)
                                    }
                                }else{
                                    try! realm.write {
                                        for i in 0..<notifications.count{
                                            realm.create(NotificationsList.self,value: ["pushID":notifications[i].pushID,"type":notifications[i].type,"title":notifications[i].title,"message":notifications[i].message,"name":notifications[i].name,"packageName":notifications[i].packageName,"email":notifications[i].email,"childID":notifications[i].childID,"sound":notifications[i].sound,"priority":notifications[i].priority,"seen":notifications[i].seen], update : true)
                                        }
                                    }
                                }
                            }
                            
                            success()
                        }
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
        
    }
}
