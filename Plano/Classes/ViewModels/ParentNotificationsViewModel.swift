//
//  ParentNotificationsViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class ParentNotificationsViewModel{
    
    var notificationIDs : [Int]?
    var seen : String?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var beforeSeenCall : (() -> Void)?
    var afterSeenCall : (() -> Void)?
    
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
    
    func updateNotificationsSeen(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj(){
            
            let data = UpdateNotiSeenRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.notiIDList = notificationIDs!
            data.seen = seen!
            
            if ReachabilityUtil.shareInstance.isOnline(){
            
                beforeSeenCall?()
                
                ParentApiManager.sharedInstance.updateNotificationSeen(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterSeenCall?()
                    
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


