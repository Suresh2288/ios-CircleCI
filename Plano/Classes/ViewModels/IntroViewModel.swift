//
//  IntroViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 25/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class IntroViewModel {
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var childRecordIsUpdated : ((_ profileData: ProfileData) -> Void)?
    
    func shouldShowParentDashboard() -> Bool {
        
        if let p = ProfileData.getProfileObj() {
            if !p.accessToken.isEmpty {
                return true
            }
        }
        
        return false
    }
    
    func shouldShowChildDashboard() -> Bool {
        
        if let p = ActiveChildProfile.getProfileObj(), let act = Defaults[.childAccessToken] {
            return !act.isEmpty
        }
        
        return false
    }
    
    func getChildRecord(completed: @escaping ((_ hasChildRecords:Bool ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            ChildApiManager.sharedInstance.getChildProfiles { (apiResponseHandler, error) in
                
                if apiResponseHandler.isSuccess() {
                    
                    // convert from json to Realm/ObjectMapper
                    if let response = Mapper<ChildProfilesResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let profiles = response.profiles {
                            
                            // Save ChildProfiles into Realm
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(ChildProfile.self)) // clear old one
                                
                                for childProfile in profiles {
                                    realm.add(childProfile)
                                }
                            }
                            
                            completed(profiles.count > 0)
                            return
                        }
                        
                    }
                    
                }
                
                completed(false) // api failed or no profiles
                
            }
        }
    }
}

