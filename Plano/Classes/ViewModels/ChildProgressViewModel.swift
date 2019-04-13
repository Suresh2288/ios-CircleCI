//
//  ChildProgressViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 5/19/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class ChildProgressViewModel{
    
    var childID : Int?
    
    var progressDate : String?
    var dateUsed : String?

    var blockBrowser : Int?
    var posture : Int?
    var childLock : Int?
    
    var weeklyReportActive : String?
    var monthlyReportActive : String?
    
    var completionCounter : Int = 0
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var progressBeforeApiCall : (() -> Void)?
    var progressAfterApiCall : (() -> Void)?
    
    var rewardsBeforeApiCall : (() -> Void)?
    var rewardsAfterApiCall : (() -> Void)?
    
    func getCustomiseSettingsSummary(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
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
    
    func updateBlockBrowser(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = BlockBrowserSettingData()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.blockBrowser = blockBrowser
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateBlockBrowserState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        CustomiseSettingsSummary.updateBlockBrowserState(state: String(describing: self?.blockBrowser))
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
                
            }
        }
    }
    
    func updatePosture(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = PostureActiveSettingData()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.posture = posture
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updatePostureState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        CustomiseSettingsSummary.updateBlockBrowserState(state: String(describing: self?.posture))
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
                
            }
        }
    }
    
    func getProgress(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
       
        if let profile = ProfileData.getProfileObj() {
            
            let data = ProgressRequest()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.progressDate = progressDate!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getProgress(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ProgressResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let childProgress = response.progress{
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(ChildProgress.self))
                                    realm.add(childProgress)
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
    
    func getTimeUsage(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = TimeUsageRequest()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.dateUsed = dateUsed!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getTimeUsage(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<TimeUsageResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let timeUsage = response.timeUsage{
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(TimeUsage.self))
                                    realm.add(timeUsage)
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
    
    func updateChildLock(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String, _ errorCode : UInt ) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = RemoteLockData()
            data.email = profile.email
            data.childID = childID
            data.accessToken = profile.accessToken
            data.childLock = childLock
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateChildLockState(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<RemoteLockResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let lockStatus = response.lockStatus {
                                
                                CustomiseSettingsSummary.updateChildLock(state: String(describing:lockStatus))
                                
                            }
                            if let blockAppActive = response.blockAppActive {
                                
                                CustomiseSettingsSummary.updateBlockAppState(state: String(describing:blockAppActive))
                                
                            }
                            if let blockBrowserActive = response.blockBrowserActive {
                                
                                CustomiseSettingsSummary.updateBlockBrowserState(state: String(describing:blockBrowserActive))
                                
                            }
                            success()
                        }
                        
                    }else{
                        failure(apiResponseHandler.errorMessage(),apiResponseHandler.errorCode!)
                    }
                })
            }
        }
    }
    
    func getRewards(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = GetRewardsRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.childID = childID
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                rewardsBeforeApiCall?()
                
                ParentApiManager.sharedInstance.getRewards(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.rewardsAfterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetRewardsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let totalPoints = response.totalPoints{
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(TotalPoints.self))
                                    realm.add(totalPoints)
                                }
                            }
                            
                            if let wishList = response.wishList{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(WishList.self))
                                    realm.add(wishList)
                                }
                            }
                            
                            if let suggestedList = response.suggestedList{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(SuggestedList.self))
                                    realm.add(suggestedList)
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
    
    func getMyopiaLastRecordsAndReport(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = ReportAndMyopiaRequest()
            data.email = profile.email
            data.childID = childID!
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                progressBeforeApiCall?()
                
                ParentApiManager.sharedInstance.getLastMyopiaAndReports(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.progressAfterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ReportAndMyopiaResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let reportsSetting = response.reportAndMyopiaData{
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(ReportAndMyopiaData.self))
                                    realm.add(reportsSetting)
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
    
//    func getChildEyeCheck(completed: @escaping ((ApiResponseHandler ) -> Void)) {
//        
//        if ReachabilityUtil.shareInstance.isOnline(){
//            
//            // Get data from API
//        ChildApiManager.sharedInstance.getChildEyeCheck(childID:String(self.childID!)) { (apiResponseHandler, error) in
//            
//                completed((apiResponseHandler))
//            }
//        }
//    }
//    
//    func getChildEyeHealth(completed: @escaping ((ApiResponseHandler ) -> Void)) {
//        
//        if ReachabilityUtil.shareInstance.isOnline(){
//            
//            // Get data from API
//        ChildApiManager.sharedInstance.getChildEyeHealth(childID:String(self.childID!)) { (apiResponseHandler, error) in
//            
//                completed((apiResponseHandler))
//            }
//        }
//    }
    
    func updateReports(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateReports()
            data.email = profile.email
            data.childID = String(describing: childID!)
            data.accessToken = profile.accessToken
            // 0 or 1
            data.weeklyReportActive = weeklyReportActive!
            data.monthlyReportActive = monthlyReportActive!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateReports(data, completed: {[weak self] (apiResponseHandler,error) in
                    
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
    
    func deleteChild(success: @escaping (_ message: String) -> Void,
                     failure: @escaping (_ errorMessage: String) -> Void){
        if let profile = ProfileData.getProfileObj(){
            let data = ChildProfileStatusRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.childID = self.childID!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.deleteChild(data, completed: {[weak self] (apiResponseHandler,error) in
                    
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
}
