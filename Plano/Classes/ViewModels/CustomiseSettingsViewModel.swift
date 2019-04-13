//
//  CustomiseSettingsViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import Validator
import FCUUID

class CustomiseSettingsViewModel{
    
    var childID : Int?
    var custSettingID : Int?
    
    // Schedule
    var scheduleID : Int?
    var schedulePeriod : String?
    var scheduleTitle : String?
    var fromTime : String?
    var toTime : String?
    var subScheduleActive : String?
    
    // Location
    var locationID : Int?
    var locationDescription : String?
    var latitude : Double?
    var longitude : Double?
    var placeID : String?
    var address : String?
    var addressTitle : String?
    var zoomsize : Int?
    var subLocationActive : String?
    
    // Block Apps [App Rating]
    var appRating : String?
    
    // Customise Settings
    var scheduleActive : Int?
    var blockAppActive : Int?
    var locationActive : Int?
    var locationList : [UpdatedLocationsList]?
    var scheduleList : [UpdatedSchedulesList]?
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var locationActiveByID : Bool?
    
    var selectedAppRating:AppRatingMDM? {
        didSet {
            log.debug(self.selectedAppRating)
        }
    }
    
    func getCustomiseSettings(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = MoreCustomiseSettingsRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.childID = childID
            data.identifierForVendor = FCUUID.uuidForDevice()
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getCustomiseSettings(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<MoreCustomiseSettingsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let customiseSettings = response.customiseSettings{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(CustomiseSettings.self))
                                    realm.add(customiseSettings)
                                }
                                
                            }
                            
                            if let locationSettings = response.locationSettings{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(LocationSettingsData.self))
                                    realm.add(locationSettings)
                                }
                                
                            }
                            
                            if let scheduleSettingsData = response.scheduleSettingsData{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ScheduleSettingsData.self))
                                    realm.add(scheduleSettingsData)
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
    
    func getChildCustomiseSettings(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj(), let acp = ActiveChildProfile.getProfileObj() {
            
            let data = MoreCustomiseSettingsRequest()
            data.email = profile.email
            data.accessToken = acp.accessToken!
            data.childID = Int(acp.childID)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ChildApiManager.sharedInstance.getChildCustomiseSettings(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<MoreCustomiseSettingsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let customiseSettings = response.customiseSettings{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(CustomiseSettings.self))
                                    realm.add(customiseSettings)
                                }
                                
                            }
                            
                            if let locationSettings = response.locationSettings{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(LocationSettingsData.self))
                                    realm.add(locationSettings)
                                }
                                
                            }
                            
                            if let scheduleSettingsData = response.scheduleSettingsData{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ScheduleSettingsData.self))
                                    realm.add(scheduleSettingsData)
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
    
    func updateScheduele(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String,_ errorCode : UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = ScheduleActiveSettingData()
            data.email = profile.email
            data.custSettingID = custSettingID
            data.accessToken = profile.accessToken
            data.scheduleActive = scheduleActive
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateScheduleState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        CustomiseSettingsSummary.updateScheduleState(state: String(describing: self?.scheduleActive))
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage(), apiResponseHandler.errorCode!)
                    }
                })
            }
        }
    }
    
    func updateLocationBoundaries(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode : UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = LocationBoundariesData()
            data.email = profile.email
            data.custSettingID = custSettingID
            data.accessToken = profile.accessToken
            data.locationActive = locationActive
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateLocationBoundariesState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        CustomiseSettingsSummary.updateLocationBoundaries(state: String(describing: self?.locationActive))
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                    }
                })
            }
        }
    }
    
    func updateBlockApp(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode : UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = BlockAppSettingData()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.blockApp = blockAppActive
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateBlockAppsState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        CustomiseSettingsSummary.updateBlockAppState(state: String(describing: self?.blockAppActive))
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage(), apiResponseHandler.errorCode!)
                    }
                })
            }
        }
    }
    
    func createSchedule(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = CreateScheduleRequest()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.schedulePeriod = schedulePeriod!
            data.title = scheduleTitle!
            if let ft = fromTime, let convertedUTC = ft.convertToUTCTimestamp() {
                data.fromTime = convertedUTC
            }
            if let tt = toTime, let convertedUTC = tt.convertToUTCTimestamp() {
                data.toTime = convertedUTC
            }
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.createSchedule(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func updateSchedule(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateScheduleRequest()
            data.email = profile.email
            data.scheduleID = scheduleID
            data.accessToken = profile.accessToken
            data.schedulePeriod = schedulePeriod!
            data.title = scheduleTitle!
            if let ft = fromTime, let convertedUTC = ft.convertToUTCTimestamp() {
                data.fromTime = convertedUTC
            }
            if let tt = toTime, let convertedUTC = tt.convertToUTCTimestamp() {
                data.toTime = convertedUTC
            }
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateSchedule(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func deleteSchedule(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = DeleteScheduleRequest()
            data.email = profile.email
            data.scheduleID = scheduleID!
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.deleteSchedule(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success(apiResponseHandler.message!)
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func createLocation(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String,_ errorCode: UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = CreateLocationRequest()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.descriptionTitle = locationDescription!
            data.latitude = latitude!
            data.longitude = longitude!
            data.placeID = placeID!
            data.address = address!
            data.addressTitle = addressTitle!
            data.zoomsize = zoomsize!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.createLocation(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                        
                    }
                })
            }
        }
    }
    
    func updateLocation(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode: UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateLocationRequest()
            data.email = profile.email
            data.locationID = locationID
            data.accessToken = profile.accessToken
            data.descriptionTitle = locationDescription!
            data.latitude = latitude!
            data.longitude = longitude!
            data.placeID = placeID!
            data.address = address!
            data.addressTitle = addressTitle!
            data.zoomsize = zoomsize!
            data.active = locationActiveByID
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateLocation(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                        
                    }
                })
            }
        }
    }
    
    func deleteLocation(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String,_ errorCode: UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = DeleteLocationRequest()
            data.email = profile.email
            data.locationID = locationID!
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.deleteLocation(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success(apiResponseHandler.message!)
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                        
                    }
                })
            }
        }
    }
    
    func getAppRating(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj(), let cid = childID {
            
            let request = AppRatingRequest(accessToken: profile.accessToken, email: profile.email, childID: String(describing: cid))
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getAppRating(request, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<AppRatingResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let listnotification = response.listnotification{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(AppRatingMDM.self))
                                    realm.add(listnotification)
                                }
                                
                            }
                            
                        }
                        
                        success("")
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
        
    }
    
    func updateSubScheduleActive(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateBlockSubScheduleRequest()
            data.email = profile.email
            data.scheduleID = String(describing: scheduleID!)
            data.accessToken = profile.accessToken
            data.scheduleActive = subScheduleActive!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateBlockSubSchedule(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func updateBlockiOSApp(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode: UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateBlockAppiOSRequest()
            data.email = profile.email
            data.appRating = appRating!
            data.accessToken = profile.accessToken
            data.childID = String(describing: childID!)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateBlockAppiOS(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                        
                    }
                })
            }
        }
    }
    
    func updateSubLocationActive(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode: UInt) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateBlockSubLocationRequest()
            data.email = profile.email
            data.locationID = String(describing: locationID!)
            data.accessToken = profile.accessToken
            data.locationActive = subLocationActive!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateBlockSubLocation(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                        
                    }
                })
            }
        }
    }
    
}

