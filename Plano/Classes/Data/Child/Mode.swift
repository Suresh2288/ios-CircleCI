//
//  ChildData.swift
//  Plano
//
//  Created by Paing Pyi on 25/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import FCUUID

class ChildModeRequest: NSObject, Mappable {
    
    @objc dynamic var email = ""
    @objc dynamic var deviceID = ""
    @objc dynamic var deviceType = ""
    @objc dynamic var accessToken = ""
    @objc dynamic var childID = ""
    @objc dynamic var identifierForVendor:String?
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : String, identifierForVendor:String) {
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
        self.identifierForVendor = identifierForVendor
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        identifierForVendor <- map["IdentifierForVendor"]
        languageID <- map["LanguageID"]

    }
}

class SwitchChildProfileResponse: NSObject, Mappable {
    
    @objc dynamic var childAccessToken:String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        childAccessToken <- map["Data.Child_Access_Token"]
    }
    
}

class ParentModeRequest: NSObject, Mappable {
    
    @objc dynamic var email = ""
    @objc dynamic var accessToken = ""
    @objc dynamic var password = ""
    @objc dynamic var deviceID = ""
    @objc dynamic var deviceType = ""
    @objc dynamic var childID = ""
    @objc dynamic var identifierForVendor = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
    }
    
    init(email: String, accessToken: String, childID: String, password: String) {
        self.email = email
        self.accessToken = accessToken
        self.password = password
        self.childID = childID
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
        self.identifierForVendor = FCUUID.uuidForDevice()
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        password <- map["Password"]
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        childID <- map["ChildID"]
        identifierForVendor <- map["IdentifierForVendor"]
        languageID <- map["LanguageID"]

    }
}

class SwitchParentProfileResponse: NSObject, Mappable {
    
    @objc dynamic var accessToken:String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        accessToken <- map["Data.Access_Token"]
    }
    
}

class ChildLogOutRequest: NSObject, Mappable {
    
    var accessToken = ""
    var childID = ""
    var identifierForVendor = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(accessToken: String, childID: String) {
        self.accessToken = accessToken
        self.childID = childID
        self.identifierForVendor = FCUUID.uuidForDevice()
    }
    
    func mapping(map: Map) {
        
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        identifierForVendor <- map["IdentifierForVendor"]
        languageID <- map["LanguageID"]

    }
}

class ResetChildModeRequest: NSObject, Mappable {
    
    var accessToken = ""
    var childID = ""
    var email = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email: String, accessToken: String, childID: String) {
        self.accessToken = accessToken
        self.childID = childID
        self.email = email
    }
    
    func mapping(map: Map) {
        
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        email <- map["email"]
        languageID <- map["LanguageID"]
        
    }
}


