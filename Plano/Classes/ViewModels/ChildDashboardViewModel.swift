//
//  ChildDashboardViewModel.swift
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

class ChildDashboardViewModel {
    
    var selectedChildID:Int?
    var password:String?
    
    var selectedAvatarGroup:Results<AvatarItem>?
    var selectedAvatarItem:AvatarItem?    
    
    var afterApiCall : (() -> Void)?
    var beforeApiCall : (() -> Void)?
    var setActiveToExistingItem : ((_ success:Bool) -> Void)?
    var buyNewItem : ((_ validation:ValidationObj) -> Void)?
    
    var activeChildProfile:ActiveChildProfile?

    // MARK: - Notification
    
    init(){
        if activeChildProfile == nil {
            activeChildProfile = ActiveChildProfile.getProfileObj()
        }
    }
    
    // MARK: - Child Profile
    
    
    
    func getSingleChildProfile(completed: @escaping ((_ profile:ChildProfile?) -> Void)) {
        beforeApiCall?()

        guard let childProfile = activeChildProfile else {
            return
        }
        
        guard let accessToken = Defaults[.childAccessToken] else {
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){

            ChildApiManager.sharedInstance.getSingleChildProfile(childID: childProfile.childID, childAccessToken:accessToken) { (apiResponseHandler, error) in
                
                if apiResponseHandler.isSuccess() {
                    
                    // convert from json to Realm/ObjectMapper
                    if let response = Mapper<ChildSingleProfileResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        
                        // Save ChildProfiles into Realm
                        let realm = try! Realm()
                        
                        if let data = response.profile
                        {
                            // clear Active child profile
                            try! realm.write {
                                //                            realm.add(data, update: true)
                                realm.create(ActiveChildProfile.self, value: data, update: true)
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
    
    func switchToParentMode(completed: @escaping ((_ validationObj: ValidationObj) -> Void)) {
        
        if let profile = ProfileData.getProfileObj(),
            let childProfile = activeChildProfile,
            let accessToken = Defaults[.childAccessToken],
            let pw = password {
            
            let requestParam = ParentModeRequest(email: profile.email, accessToken: accessToken, childID: childProfile.childID, password: pw)
            
            if ReachabilityUtil.shareInstance.isOnlineWithNativePopup(){
                
                beforeApiCall?()
                
                // Get data from API
                ChildApiManager.sharedInstance.switchToParentMode(requestParam, completed: { (apiResponseHandler, error) in
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        // convert from json to Realm/ObjectMapper
                        if let response = Mapper<SwitchParentProfileResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let act = response.accessToken {
                                
                                // clear Game Items
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(AvatarItem.self))
                                }
                                
                                // clear Child Session
                                ChildSessionManager.sharedInstance.switchToParentMode()
                                
                                // save new AccessToken of Parent
                                ProfileData.updateAccessToken(token: act)
                                
                                // remove childToken and set 0 as Active
                                self.destroyChildSession()
                                
                                completed(ValidationObj(isValid: true,
                                                        error: nil))
                                return
                            }
                            
                        }
                        
                        completed(ValidationObj(isValid: false,
                                                error: ValidationError(message: apiResponseHandler.errorMessage())))
                        
                    }else{
                        completed(ValidationObj(isValid: false,
                                                error: ValidationError(message: apiResponseHandler.errorMessage())))
                        
                    }
                    
                })
                
            }else{
                completed(ValidationObj(isValid: false,
                                        error: ValidationError(message: "No internet connection")))
            }
            
        }
        
    }
    
    func destroyChildSession(){

        let realm = try! Realm()

        // clear Child Token from NSUserDefaults
        Defaults[.childAccessToken] = nil
        let children = realm.objects(ActiveChildProfile.self)
        
        // clear Active child profile
        try! realm.write {
            
            // in-active to all children. We set it to all to be more robus.
            children.setValue(0, forKeyPath: "isActive")
            
            // clear all sessions
            children.setValue("", forKeyPath: "accessToken")
        }
    }
    
    /**
     * Customise Avatar
     **/
    
    func getAllAvatarItems(completed: @escaping ((_ list:Results<AvatarItem>) -> Void)) {
        
        if let childProfile = activeChildProfile, let accessToken = Defaults[.childAccessToken]{
                
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                let requestParam = AvatarItemsRequest(childID: childProfile.childID, accessToken:accessToken )
                
                ChildApiManager.sharedInstance.getAvatarItems(requestParam, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    // Save ChildProfiles into Realm
                    let realm = try! Realm()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        // convert from json to Realm/ObjectMapper
                        if let response = Mapper<AvatarItemResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            
                            // clear all first
                            //                        try! realm.write {
                            //                            realm.delete(realm.objects(AvatarItem.self))
                            //                        }
                            
                            for item in response.items {
                                
                                // create or update
                                try! realm.write {
                                    
                                    // add into Realm
                                    realm.add(item, update: true)
                                    
                                }
                            }
                        }
                    }
                    
                    self.selectedAvatarGroup = realm.objects(AvatarItem.self)
                    completed(self.selectedAvatarGroup!)
                    
                })
            }
        }

    }
    
    func getActiveHatItem() -> AvatarItem? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "itemCategory = 'Hat' AND bought = %@ AND active = %@", NSNumber(booleanLiteral: true), NSNumber(booleanLiteral: true))
        let item = realm.objects(AvatarItem.self).filter(predicate).first
        return item
    }
    func getActiveBadgeItem() -> AvatarItem? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "itemCategory = 'Badge' AND bought = %@ AND active = %@", NSNumber(booleanLiteral: true), NSNumber(booleanLiteral: true))
        let item = realm.objects(AvatarItem.self).filter(predicate).first
        return item
    }
    func getActiveGlassesItem() -> AvatarItem? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "itemCategory = 'Glasses' AND bought = %@ AND active = %@", NSNumber(booleanLiteral: true), NSNumber(booleanLiteral: true))
        let item = realm.objects(AvatarItem.self).filter(predicate).first
        return item
    }
    
    func getHatList() -> Results<AvatarItem>{
        let realm = try! Realm()
        selectedAvatarGroup = realm.objects(AvatarItem.self).filter("itemCategory = 'Hat'")
        return selectedAvatarGroup!
    }
    func getBadgeList() -> Results<AvatarItem>{
        let realm = try! Realm()
        selectedAvatarGroup = realm.objects(AvatarItem.self).filter("itemCategory = 'Badge'")
        return selectedAvatarGroup!
    }
    func getGlassesList() -> Results<AvatarItem>{
        let realm = try! Realm()
        selectedAvatarGroup = realm.objects(AvatarItem.self).filter("itemCategory = 'Glasses'")
        return selectedAvatarGroup!
    }
    
    func buyAvatarItem(completed: @escaping ((_ validationObj: ValidationObj) -> Void)){
        
        if let gameItem = selectedAvatarItem, let accessToken = Defaults[.childAccessToken], let childProfile = activeChildProfile{
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                let request = AddNewGameItemRequest(childID: childProfile.childID, accessToken: accessToken, gameItemID: gameItem.gameItemID)
                ChildApiManager.sharedInstance.addNewGameItem(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<AddNewGameItemResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                childProfile.gamePoint = response.points
                            }
                        }
                        
                        self.getAllAvatarItems(completed: { (results) in
                            
                            completed(ValidationObj(isValid: true,
                                                    error: ValidationError(message: apiResponseHandler.errorMessage())))
                            
                            self.getPlanoPoints()
                        })
                        
                    }else{
                        
                        completed(ValidationObj(isValid: false,
                                                error: ValidationError(message: apiResponseHandler.errorMessage())))
                    }
                    
                })
            }
        }
    }

    func setActiveAvatarItem(completed: @escaping ((_ success:Bool) -> Void)){
        
        if let gameItem = selectedAvatarItem, let accessToken = Defaults[.childAccessToken], let childProfile = activeChildProfile{
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                let request = GameItemStatusRequest(childID: childProfile.childID, accessToken: accessToken, gameItemID: gameItem.gameItemID)
                
                ChildApiManager.sharedInstance.updateGameItemStatus(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        self.getAllAvatarItems(completed: { (results) in
                            completed(true)
                        })
                        
                    }else{
                        completed(false)
                    }
                    
                })
            }
        }
    }
    
    func performBuyAction(){
        if let data = self.selectedAvatarItem {
            // if item is bought and not active, setActiveToExistingItem
            // if item is NOT bought, buyNewItem
            if data.bought && !data.active {
                
                _setActiveToExistingItem()
                
            }else if !data.bought {
                _buyNewItem()
            }
        }
    }
    
    func _setActiveToExistingItem(){
        setActiveAvatarItem { (success) in
            self.setActiveToExistingItem?(success)
        }
    }
    
    func _buyNewItem(){
        buyAvatarItem { (success) in
            self.buyNewItem?(success)
        }
    }
    
    // MARK: - Game
    
    func userCanPlayGame() -> Bool {
        if let cp = activeChildProfile, let gamePoint = cp.gamePoint.toInt() {
            return cp.remainingGamePlayPerDay > 0 && gamePoint > 99
        }
        return false
    }
    
    func deductPointForPlayingGame(gameName:String, completed: @escaping ((_ success:Bool) -> Void)){
        
        // deduct game play count
        if let childProfile = activeChildProfile {
            childProfile.updateRemainingGamePlayCount()
        }
        
        if let childProfile = activeChildProfile, let accessToken = Defaults[.childAccessToken] {
            let request = UpdateChildGameRequest(childID: childProfile.childID, accessToken: accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                self.beforeApiCall?()
                
                // cannot play for today
                ChildApiManager.sharedInstance.updateChildGamePoint(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        self.getPlanoPoints()
                        
                        completed(true)
                    } else {
                        completed(false)
                    }
                    
                })
            }
            
        }
        
    }
    
    func getPlanoPoints(){
        
        if let childProfile = ChildSessionManager.sharedInstance.getActiveChildProfile(), let accessToken = Defaults[.childAccessToken] {
            let request = GetChildPlanoPointsRequest(childID: childProfile.childID, accessToken: accessToken)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                self.beforeApiCall?()
                
                ChildApiManager.sharedInstance.getChildPlanoPoints(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetPlanoPointsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            //success(response.childID)
                            
                            print(response.ChildPlanoPoint)
                            // store point from server
                            let realm = try! Realm()
                            try! realm.write {
                                childProfile.gamePoint = String(response.ChildPlanoPoint)
                            }
                        }
                        
                    }
                    
                    //                    if apiResponseHandler.isSuccess() {
                    //
                    //                        let dict = apiResponseHandler.jsonObject as! NSDictionary
                    //                        let dictData = dict.value(forKey: "Data")
                    //                        let ChildPlanoPoints = (dictData as AnyObject).value(forKey: "ChildPlanoPoints") as! Int
                    //
                    //                        // store point from server
                    //                        let realm = try! Realm()
                    //                        try! realm.write {
                    //                            childProfile.gamePoint = String(ChildPlanoPoints)
                    //                        }
                    //                    }
                    
                })
                
            }
            
        }
        
    }
    
    func addPointForWinningGame(gameName:String, durationSeconds:String, completed: @escaping ((_ success:Bool) -> Void)){
        
        let sessionNumber = UserDefaults.standard.string(forKey: "ChildSessionNumber")
        
        if let childProfile = activeChildProfile, let accessToken = Defaults[.childAccessToken] {
            
            let request = UpdateChildGameResultRequest(childID: childProfile.childID, accessToken: accessToken, updatedSeconds: durationSeconds, gameType: gameName, sessionNumber: sessionNumber!)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                self.beforeApiCall?()
                
                if (gameName == "Eyexcerise") {
                    ChildApiManager.sharedInstance.UpdateEyexceriseGameResult(request, completed: { (apiResponseHandler, error) in
                        
                        self.afterApiCall?()
                        
                        if apiResponseHandler.isSuccess() {
                            
                            let dict = apiResponseHandler.jsonObject as! NSDictionary
                            let dictData = dict.value(forKey: "Data")
                            let ChildWallet = (dictData as AnyObject).value(forKey: "ChildWallet") as! NSDictionary
                            
                            let gamePoints = (ChildWallet as AnyObject).value(forKey: "Points") as! Int
                            
                            // store point from server
                            let realm = try! Realm()
                            try! realm.write {
                                childProfile.gamePoint = String(gamePoints)
                            }
                            
                            completed(true)
                        } else {
                            completed(false)
                        }
                        
                    })
                } else if (gameName == "Pairs") {
                    ChildApiManager.sharedInstance.UpdatePlanoPairsGameResult(request, completed: { (apiResponseHandler, error) in
                        
                        self.afterApiCall?()
                        
                        if apiResponseHandler.isSuccess() {
                            
                            let dict = apiResponseHandler.jsonObject as! NSDictionary
                            let dictData = dict.value(forKey: "Data")
                            let ChildWallet = (dictData as AnyObject).value(forKey: "ChildWallet") as! NSDictionary
                            
                            let gamePoints = (ChildWallet as AnyObject).value(forKey: "Points") as! Int
                            
                            // store point from server
                            let realm = try! Realm()
                            try! realm.write {
                                childProfile.gamePoint = String(gamePoints)
                            }
                            
                            completed(true)
                        } else {
                            completed(false)
                        }
                        
                    })
                }
            }
            
        }
        
    }
    
    func checkParentPassword(completed: @escaping ((_ validationObj: ValidationObj) -> Void)){
        
        if let pw = password ,
            let childProfile = activeChildProfile,
            let profile = ProfileData.getProfileObj(),
            let accessToken = Defaults[.childAccessToken] {
            
            let request = CheckParentPasswordRequest(childID: childProfile.childID, accessToken: accessToken, password: pw, email: profile.email)
            
            if ReachabilityUtil.shareInstance.isOnlineWithNativePopup(){
                
                self.beforeApiCall?()
                
                ChildApiManager.sharedInstance.checkParentPassword(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        if let response = Mapper<CheckParentPasswordResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if response.isFound() {
                                completed(ValidationObj(isValid: true,
                                                        error: nil))
                                return
                            }
                            
                        }
                        
                        completed(ValidationObj(isValid: false,
                                                error: ValidationError(message: apiResponseHandler.errorMessage())))
                        
                    }else{
                        completed(ValidationObj(isValid: false,
                                                error: ValidationError(message: apiResponseHandler.errorMessage())))
                    }
                    
                })
            }else{
                completed(ValidationObj(isValid: false,
                                        error: ValidationError(message: "No internet connection")))
            }
            
        }
        
    }
    
    func getGameBestTime(gameTime:String, completed: @escaping ((_ success:Bool, _ message:String?) -> Void)){
        
        if let childProfile = activeChildProfile, let accessToken = Defaults[.childAccessToken] {
            
            let request = GetGameBestTimeRequest(ChildID: childProfile.childID, Access_Token: accessToken, GameTime: gameTime)
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                self.beforeApiCall?()
                
                ChildApiManager.sharedInstance.getGameBestTime(request, completed: { (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        if let response = Mapper<GetGameBestTimeResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            completed(true, response.BestTimeMessage)
                        }
                    }else{
                        completed(false,apiResponseHandler.errorMessage())
                    }
                    
                })
            }
            
        }
        
    }
    
    func getChildSessionCount(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline() {
            
            // Get session count from API
            ChildApiManager.sharedInstance.getChildSessionCount { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
        }
    }
    
    func updateChildSessionCount(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline() {
            
            // Update session count through API
            ChildApiManager.sharedInstance.updateChildSessionCount { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
        }
    }
    
    func updateScreenTime (completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Update session time through API
            ChildApiManager.sharedInstance.updateScreenTime { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
        }
    }
    
    func updateBreakSessionExtension (completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Update session break extension time through API
            ChildApiManager.sharedInstance.updateBreakSessionExtension { (apiResponseHandler, error) in
                
                completed((apiResponseHandler))
            }
        }
    }
    
    // Eye Calibration
    
    func shouldRemindToWearGlass() -> Bool {
        if let acp = self.activeChildProfile {
            if let result = acp.getWearingGlassBool() {
                return result
            }
        }
        return false
    }

}
