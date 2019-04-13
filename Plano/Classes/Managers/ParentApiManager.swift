//
//  ParentApiManager.swift
//  Plano
//
//  Created by Thiha Aung on 4/30/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SwiftyUserDefaults
import HTTPStatusCodes
import AlamofireObjectMapper

class ParentApiManager {
    
    static let sharedInstance = ParentApiManager()
    
    //MARK: - Myopia Progress
    func getMyopiaProgress(_ data:MyopiaProgressRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildMyopiaProgress(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getMyopiaProgressSummary(_ data:MyopiaProgressSummaryRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetMyopiaSummary(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateMyopiaProgress(_ data:MyopiaProgressData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildMyopiaProgress(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    //MARK: - Switch to Child Mode
    
    func switchChildMode(_ data:ChildModeRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.SwitchChildMode(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    //MARK: - Child Progress
    
    func getCustomiseSettingSummary(_ data:CustomiseSettingsSummaryRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetCustomiseSettingsSummary(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getProgress(_ data:ProgressRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetProgress(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getTimeUsage(_ data:TimeUsageRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetTimeUsage(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }

    func updateScheduleState(_ data:ScheduleActiveSettingData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateScheduleActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateBlockAppsState(_ data:BlockAppSettingData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBlockAppActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateBlockBrowserState(_ data:BlockBrowserSettingData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBlockBrowserActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateLocationBoundariesState(_ data:LocationBoundariesData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateLocationActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateChildLockState(_ data:RemoteLockData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateLock(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updatePostureState(_ data:PostureActiveSettingData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdatePosture(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getRewards(_ data:GetRewardsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetRewards(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getParentPlanoPoints(_ data:GetParentPlanoPointsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPlanoPoints(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func CheckUserStatus(_ data:GetParentPlanoPointsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CheckUserStatus(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func CheckNtucUserNric(_ data:GetParentPlanoPointsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CheckNtucUserNric(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func InsertNtucUserNric(_ data:InsertNtucUserNricRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.InsertNtucUserNric(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func UpdateNtucLinkPointsTransaction(_ data:GetParentPlanoPointsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateNtucLinkPointsTransaction(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func ResetChildModePrompt(_ data:ResetChildModeRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.ResetChildModePrompt(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func getplanoPoints(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetParentPlanoPointsRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPlanoPoints(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    //MARK: - Alert Settings
    func getAlertSettings(_ data:AlertSettingsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAlertSettings(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateAlertSettings(_ data:UpdateAlertSettingsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateAlertSettings(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    //MARK: - Linked Accounts
    func getLinkedAccounts(_ data:GetLinkedAccountsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetLinkedAccounts(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getPendingLinkedAccounts(_ data:GetPendingAccountsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPendingLinkAccount(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateLinkedAccount(_ data:UpdateLinkedAccount, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateLinkedAccount(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func rejectPendingAccount(_ data:RejectPendingAccountRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.RejectPendingLink(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func createLinkAccount(_ data:CreateLinkAccountRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CreateLinkAccount(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateRequestLink(_ data:UpdateRequestLink, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateRequestLink(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    //MARK: - Customise Settings
    
    func getCustomiseSettings(_ data:MoreCustomiseSettingsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetCustomiseSettings(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateCustomiseSettings(_ data:UpdateCustomiseSettingsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateCustomiseSettings(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }

    func createSchedule(_ data:CreateScheduleRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CreateSchedule(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func deleteSchedule(_ data:DeleteScheduleRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.DeleteSchedule(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateSchedule(_ data:UpdateScheduleRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateSchedule(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    

    func createLocation(_ data:CreateLocationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CreateLocation(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func deleteLocation(_ data:DeleteLocationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.DeleteLocation(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateLocation(_ data:UpdateLocationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateLocation(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func updateBlockSubSchedule(_ data:UpdateBlockSubScheduleRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBlockSubScheduleActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func updateBlockAppiOS(_ data:UpdateBlockAppiOSRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBlockAppiOS(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func updateBlockSubLocation(_ data:UpdateBlockSubLocationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBlockSubLocationActive(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }

    //MARK: - Log out
    
    func logOut(_ data:LogOutRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.DoLogout(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    //MARK: - Premium
    func getAllPremium(_ data:GetAllPremiumRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAllPremium(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            print(data.toJSON())
            completed(apiResponseHandler, error)
        }
    }
    
    //MARK: - Notifications
    func getNotifications(_ data:GetNotificationsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetListNotification(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func updateNotificationSeen(_ data:UpdateNotiSeenRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateNotiSeen(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    
    // MARK: - Reports and Myopia Last Update
    func getLastMyopiaAndReports(_ data:ReportAndMyopiaRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetLastMyopiaAndReports(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    // MARK: - Update Reports
    func updateReports(_ data:UpdateReports, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateReports(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
            
        }
    }
    
    // MARK: - App Rating
    func getAppRating(_ data:AppRatingRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetiOSRatingApp(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    // Delete Child
    func deleteChild(_ data:ChildProfileStatusRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildAccountStatus(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
            
        }
    }
    
}
