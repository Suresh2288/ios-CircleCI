//
//  MyFamilyViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 4/30/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import FCUUID

class MyFamilyViewModel {
    
    var selectedChildID : Int = 0
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var childRecordIsUpdated : ((_ profileData: ProfileData) -> Void)?
    var openInSafari : ((_ url: URL) -> Void)?
    
    func getChildRecord(completed: @escaping ((_ hasChildRecords:Bool ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?()
            
            // Get data from API
            ChildApiManager.sharedInstance.getChildProfiles { (apiResponseHandler, error) in
                
                self.afterApiCall?()
                
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
                    
                }else{
                    // TODO: handle failure problem
                }
                
                completed(false) // api failed or no profiles
                
            }
        }
    }
    
    
    func getPlanoRecord(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            ChildApiManager.sharedInstance.getplanoPoints { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
        }
    }
    
    
    
    func switchToChildMode(completed: @escaping ((_ success:Bool) -> Void),failure: @escaping (_ errorMessage:String, _ errorCode:UInt ) -> Void) {

        if let profile = ProfileData.getProfileObj(), selectedChildID > 0, let uuid = FCUUID.uuidForDevice() {
            
            let requestParam = ChildModeRequest(email: profile.email, accessToken: profile.accessToken, childID: String(selectedChildID), identifierForVendor: uuid)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                // Get data from API
                ParentApiManager.sharedInstance.switchChildMode(requestParam, completed: { (apiResponseHandler, error) in
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        // convert from json to Realm/ObjectMapper
                        if let response = Mapper<SwitchChildProfileResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            // Save ChildProfiles into Realm
                            let realm = try! Realm()
                            
                            if let act = response.childAccessToken {
                                
                                // store in NSDefault
                                Defaults[.childAccessToken] = act
                                
                                let children = realm.objects(ActiveChildProfile.self)
                                
                                if let childProfile = ChildProfile.getChildProfileById(childId: String(self.selectedChildID)) {
                                    
                                    try! realm.write {
                                        
                                        // disable other children to `fase` - isActive
                                        children.setValue(false, forKeyPath: "isActive")
                                        
                                        // clear all tokens
                                        children.setValue("", forKeyPath: "accessToken")
                                        
                                        // update
                                        if let acp = ActiveChildProfile.getChildProfileById(childId: "\(self.selectedChildID)") {
                                            
                                            acp.isActive = true
                                            acp.accessToken = act
                                            
                                            // TODO: to copy all ChildProfile attributes in proper way
                                            acp.firstName = childProfile.firstName
                                            acp.lastName = childProfile.lastName
                                            acp.isWearingGlass = childProfile.isWearingGlass
                                            acp.gamePoint = childProfile.gamePoint
                                        }else{
                                            let acp = realm.create(ActiveChildProfile.self, value: childProfile, update: true)
                                            acp.isActive = true
                                            acp.accessToken = act
                                        }
                                    }
                                }
                                
                                completed(true)
                                return
                            }
                            
                        }
                        
                        failure(apiResponseHandler.errorMessage(), apiResponseHandler.errorCode!)
                        
                    }else{
                        // TODO: handle failure problem
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                    }
                    
                })
            }
        
        }
        
    }
    
    func getCustomiseSettingsSummary(childID:Int, success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = CustomiseSettingsSummaryRequest()
            data.childID = childID
            data.accessToken = profile.accessToken
            data.email = profile.email
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getCustomiseSettingSummary(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<CustomiseSettingsSummaryResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let customiseSettingsSummary = response.customiseSettingsSummary{
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(CustomiseSettingsSummary.self))
                                    realm.add(customiseSettingsSummary)
                                }
                                success()
                            }
                        }
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
            
        }
    }
}
