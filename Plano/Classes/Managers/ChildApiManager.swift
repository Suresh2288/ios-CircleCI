//
//  ChildApiManager.swift
//  Plano
//
//  Created by Paing Pyi on 25/4/17.
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
import RealmSwift

class ChildApiManager {
    
    static let sharedInstance = ChildApiManager()

    func getChildProfiles(completed: @escaping completionHandler) {

        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ChildProfileRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildProfiles(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                print("data.toJSON():\(requestParam)")
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getplanoPoints(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ChildProfileRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPlanoPoints(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
//    func getChildEyeCheck(childID:String, completed: @escaping completionHandler) {
//
//        if let profile = ProfileData.getProfileObj() {
//
//            let requestParam = ChildEyeCheckRequest(email: profile.email, childId:childID, accessToken: profile.accessToken).toJSON()
//            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildEyeCheck(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
//
//                print("data.toJSON():\(requestParam)")
//                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
//
//                completed(apiResponseHandler, error)
//            }
//        }
//    }
    
    func getChildEyeCheck(_ data:ChildEyeHealthRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildEyeCheck(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            
            completed(apiResponseHandler, error)
        }
    }
    
//    func getChildEyeHealth(childID:String, completed: @escaping completionHandler) {
//
//        if let profile = ProfileData.getProfileObj() {
//
//            let requestParam = ChildEyeHealthRequest(email: profile.email, childId:childID, accessToken: profile.accessToken).toJSON()
//            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildEyeHealth(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
//
//                print("data.toJSON():\(requestParam)")
//                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
//                completed(apiResponseHandler, error)
//            }
//        }
//    }
    
    func getChildEyeHealth(_ data:ChildEyeHealthRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildEyeHealth(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            
            completed(apiResponseHandler, error)
        }
    }
    
    func getChildSessionCount(completed: @escaping completionHandler) {
        
        if let childProfile = ActiveChildProfile.getProfileObj() {
            
            let date = Date()
            let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date)/3600)
            
            let requestParam = GetChildSessionRequest(childId: childProfile.childID, accessToken: childProfile.accessToken!, timeDifference: String(timeZoneOffset)).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildSessionCount(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func updateChildSessionCount(completed: @escaping completionHandler) {
        
        if let childProfile = ActiveChildProfile.getProfileObj() {
            
            let date = Date()
            let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: date)/3600)
            
            let requestParam = UpdateChildSessionRequest(childId: childProfile.childID, accessToken: childProfile.accessToken!, deviceType: "iOS", deviceID: Defaults[.pushToken], timeDifference: String(timeZoneOffset)).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildSessionCount(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func updateScreenTime (completed: @escaping completionHandler) {
        
        if let childProfile = ActiveChildProfile.getProfileObj() {
            
            let sessionNumber = UserDefaults.standard.string(forKey: "ChildSessionNumber")
            
            let durationDate = childProfile.lastSessionStopsAt
            let elapsed = Date().timeIntervalSince(durationDate!)
            let durationSeconds = Int(elapsed)
            
            let requestParam = UpdateScreenTimeRequest(childId: childProfile.childID, accessToken: childProfile.accessToken!, durationSeconds: String(durationSeconds), sessionNumber: sessionNumber!).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateScreenTime(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func updateBreakSessionExtension (completed: @escaping completionHandler) {
        
        if let childProfile = ActiveChildProfile.getProfileObj() {
            
            let sessionNumber = UserDefaults.standard.string(forKey: "ChildSessionNumber")
            let extensionSeconds = UserDefaults.standard.string(forKey: "ExtensionSeconds")
            
            let requestParam = UpdateSessionBreakTimeRequest(childId: childProfile.childID, accessToken: childProfile.accessToken!, durationSeconds: extensionSeconds!, sessionNumber: sessionNumber!).toJSON()
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBreakSessionExtension(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getSingleChildProfile(childID:String, childAccessToken:String, completed: @escaping completionHandler) {
        
        let requestParam = ChildSingleProfileRequest(childID: childID, accessToken: childAccessToken).toJSON()
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildProfile(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
        
    }
    
    func addChildProfile(_ data:AddChildData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CreateChildProfile(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func updateChildProfile(_ data:AddChildData, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildProfile(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func updateChildPoint(_ data:UpdateChildPointRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateForceQuit(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func updateChildGamePoint(_ data:UpdateChildGameRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildGameRequest(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func getChildPlanoPoints(_ data:GetChildPlanoPointsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildPlanoPoints(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func UpdatePlanoPairsGameResult(_ data:UpdateChildGameResultRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdatePairsGameResults(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func UpdateEyexceriseGameResult(_ data:UpdateChildGameResultRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateEyexceriseGameResults(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }
    
    func switchToParentMode(_ data:ParentModeRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.SwitchParentMode(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getAvatarItems(_ data:AvatarItemsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAllGameItems(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func addNewGameItem(_ data:AddNewGameItemRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateAddNewGameItem(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateGameItemStatus(_ data:GameItemStatusRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateGameItemStatus(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func checkParentPassword(_ data:CheckParentPasswordRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.CheckParentPassword(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    
    func getChildCustomiseSettings(_ data:MoreCustomiseSettingsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildCustomiseSettings(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateLocationOutPush(_ data:ChildLocationOutPushRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateLocationOutPush(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateProgressDaily(_ data:UpdateProgressRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateProgress(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    
    func updateEyeCalibration(_ data:UpdateEyeCalibrationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateEyeCalibration(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }

    }
    
    func updateBehaviourEyeCalibration(_ data:UpdateBehaviourEyeCalibrationRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateBehaviourEyeCalibration(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updatePostureCalibration(_ data:UpdatePostureRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdatePosture(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getGameBestTime(_ data:GetGameBestTimeRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetGameBestTime(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
    func doChildLogOut(_ data:ChildLogOutRequest, completed: @escaping completionHandler){
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.ChildLogOut(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            completed(apiResponseHandler, error)
        }
        
    }
    
}
