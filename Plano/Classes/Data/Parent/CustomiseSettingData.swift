//
//  CustomiseSettingData.swift
//  Plano
//
//  Created by Thiha Aung on 5/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RealmSwift
import ObjectMapper

// TODO:  GetCustomiseSettings
// TODO:  UpdateCustomiseSettings
// TODO:  UpdateContentManagementActive

// For updating custom setting "Remotely Lock Child Device" => 1 = Active / 0 = Inactive
class RemoteLockData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var childID : Int?
    var childLock : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int, childLock : Int) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.childLock = childLock
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        childLock <- map["Lock"]
        languageID <- map["LanguageID"]

    }
}

class RemoteLockResponse : NSObject, Mappable{
    var lockStatus : String?
    var blockAppActive : String?
    var blockBrowserActive : String?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        lockStatus <- map["Data.LockStatus"]
        blockAppActive <- map["BlockAppActive"]
        blockBrowserActive <- map["BlockBrowserActive"]
    }
}

// For updating custom setting "LocationBoundaries" => 1 = Active / 0 = Inactive
class LocationBoundariesData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var custSettingID : Int?
    var locationActive : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, custSettingID : Int, locationActive : Int) {
        self.email = email
        self.accessToken = accessToken
        self.custSettingID = custSettingID
        self.locationActive = locationActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        custSettingID <- map["CustSettingID"]
        locationActive <- map["LocationActive"]
        languageID <- map["LanguageID"]

    }
}

// For updating custom setting "BlockBrowser" => 1 = Active / 0 = Inactive
class BlockBrowserSettingData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var childID : Int?
    var blockBrowser : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int, blockBrowser : Int) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.blockBrowser = blockBrowser
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        blockBrowser <- map["BlockBrowser"]
        languageID <- map["LanguageID"]

    }
}

class PostureActiveSettingData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var childID : Int?
    var posture : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int, posture : Int) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.posture = posture
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        posture <- map["PostureActive"]
        languageID <- map["LanguageID"]

    }
}

// For updating custom setting "BlockApp" => 1 = Active / 0 = Inactive
class BlockAppSettingData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var childID : Int?
    var blockApp : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int, blockApp : Int) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.blockApp = blockApp
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        blockApp <- map["BlockApp"]
        languageID <- map["LanguageID"]

    }
}

// For updating custom setting "BlueFilter" => 1 = Active / 0 = Inactive
class BlueFilterSettingData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var childID : Int?
    var blueFilterActive : Int?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int, blueFilterActive : Int) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.blueFilterActive = blueFilterActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        blueFilterActive <- map["BlueFilterActive"]
    }
}

// For updating custom setting "Schedule" => 1 = Active / 0 = Inactive
class ScheduleActiveSettingData : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var custSettingID : Int?
    var scheduleActive : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, custSettingID : Int, scheduleActive : Int) {
        self.email = email
        self.accessToken = accessToken
        self.custSettingID = custSettingID
        self.scheduleActive = scheduleActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        custSettingID <- map["CustSettingID"]
        scheduleActive <- map["ScheduleActive"]
        languageID <- map["LanguageID"]

    }
}
