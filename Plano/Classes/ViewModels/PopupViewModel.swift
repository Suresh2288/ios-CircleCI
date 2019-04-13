//
//  PopupViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 1/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class PopupViewModel {
    
//    var selectedChildID:Int?
//    var password:String?
//    
//    var selectedAvatarGroup:Results<AvatarItem>?
//    var selectedAvatarItem:AvatarItem?    
    
    var afterApiCall : (() -> Void)?
    var beforeApiCall : (() -> Void)?

//    var setActiveToExistingItem : ((_ success:Bool) -> Void)?
//    var buyNewItem : ((_ validation:ValidationObj) -> Void)?
    
    var activeChildProfile:ActiveChildProfile?

    // MARK: - Notification
    
    init(){
        if activeChildProfile == nil {
            activeChildProfile = ActiveChildProfile.getProfileObj()
        }
    }
    
    // MARK: - Child Profile
    
    func getSingleChildProfile(completed: @escaping ((_ profile:ChildProfile?) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?()
            
            guard let childProfile = activeChildProfile else {
                return
            }
            
            guard let accessToken = Defaults[.childAccessToken] else {
                return
            }
            
            ChildApiManager.sharedInstance.getSingleChildProfile(childID: childProfile.childID, childAccessToken:accessToken) { (apiResponseHandler, error) in
                
                if apiResponseHandler.isSuccess() {
                    
                    // convert from json to Realm/ObjectMapper
                    if let response = Mapper<ChildSingleProfileResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        
                        // Save ChildProfiles into Realm
                        let realm = try! Realm()
                        
                        if let data = response.profile {
                            
                            // clear Active child profile
                            try! realm.write {
                                realm.add(data, update: true)
                            }
                            
                            completed(data)
                            return
                        }
                        
                    }
                    
                    completed(nil)
                    
                }else{
                    completed(nil)
                    
                }
            }
        }
    }
    
    func checkParentPasswordSuccess(){
        ChildSessionManager.sharedInstance.continueDeviceUsageWithPermission(deductPoint:0)
    }
    
}
