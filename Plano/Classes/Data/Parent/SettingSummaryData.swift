//
//  SettingSummaryData.swift
//  Plano
//
//  Created by Thiha Aung on 5/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class CustomiseSettingsSummary : Object,Mappable{
   
    @objc dynamic var custSettingID = ""
    @objc dynamic var scheduleActive = ""
    @objc dynamic var locationActive = ""
    @objc dynamic var contentActive = ""
    @objc dynamic var blueScreenActive = ""
    @objc dynamic var blueFilterMode = ""
    @objc dynamic var blockAppActive = ""
    @objc dynamic var blockBrowserActive = ""
    @objc dynamic var childLock = ""
    @objc dynamic var posture:String?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        custSettingID <- map["CustSettingID"]
        scheduleActive <- map["ScheduleActive"]
        locationActive <- map["LocationActive"]
        contentActive <- map["ContentActive"]
        blueScreenActive <- map["BlueScreenActive"]
        blueFilterMode <- map["BlueFilterMode"]
        blockAppActive <- map["BlockAppActive"]
        blockBrowserActive <- map["BlockBrowserActive"]
        childLock <- map["ChildLock"]
        posture <- map["Posture"]
    }
    
    static func getCustomiseSettingSummaryObj() -> CustomiseSettingsSummary? {
        let realm = try! Realm()
        return realm.objects(CustomiseSettingsSummary.self).first
    }
    
    static func clearCustomiseSettingSummaryObj() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CustomiseSettingsSummary.self))
        }
    }
    
    static func updateScheduleState(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.scheduleActive = state
            }
        }
    }
    
    static func updateBlockAppState(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.blockAppActive = state
            }
        }
    }
    
    static func updateBlockBrowserState(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.blockBrowserActive = state
            }
        }
    }
    
    static func updateLocationBoundaries(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.locationActive = state
            }
        }
    }
    
    static func updateChildLock(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.childLock = state
            }
        }
    }
    
    static func updatePosture(state: String) {
        let realm = try! Realm()
        if let settings = self.getCustomiseSettingSummaryObj() {
            try! realm.write {
                settings.posture = state
            }
        }
    }
    
    func isLocationOptionActive() -> Bool {
        if let active = self.locationActive.toBool() {
            return active
        }else{
            return false
        }
    }
    
    func shouldCalibratePosture() -> Bool {
        if let post = self.posture {
            return post.toBool()!
        }
        return false
    }
}

class CustomiseSettingsSummaryResponse : NSObject,Mappable{
    
    @objc dynamic var customiseSettingsSummary : CustomiseSettingsSummary?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        customiseSettingsSummary <- map["Data"]
    }
}

class CustomiseSettingsSummaryRequest : NSObject,Mappable{
    
    var email : String = ""
    var childID : Int?
    var accessToken : String = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String){
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
}
