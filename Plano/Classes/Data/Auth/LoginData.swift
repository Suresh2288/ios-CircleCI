//
//  LoginData.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class LoginData: NSObject, Mappable {
    
    var email = ""
    var password = ""
    var deviceID = ""
    var deviceType = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(email: String?, password: String?) {
        
        self.email = email!
        self.password = password!
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        password <- map["Password"]
        
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        languageID <- map["LanguageID"]

    }
}

class LoginDataResponse: NSObject, Mappable {
    
    @objc dynamic var profile: ProfileData?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profile <- map["Data.profile"]
    }
    
}

class GetProfileRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(email: String, accessToken: String) {
        
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

/////////////////


class FacebookLoginData: NSObject, Mappable {

    var email = ""
    var fbToken = ""
    var deviceID = ""
    var deviceType = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){

    }

    init(email: String, fbToken: String) {

        self.email = email
        self.fbToken = fbToken
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
    }

    func mapping(map: Map) {

        email <- map["Email"]
        fbToken <- map["Facebook_Access_Token"]

        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        languageID <- map["LanguageID"]

    }
}

/////////////////

class CheckAccountBeforeRegisterRequest: NSObject, Mappable {
    
    var email = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var appsflyerID = ""
    var ipAddress = ""

    required init?(map: Map){
        
    }
    
    init(email: String, appsflyerID: String, ipAddress: String) {
        self.email = email
        self.appsflyerID = appsflyerID
        self.ipAddress = ipAddress
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        languageID <- map["LanguageID"]
        appsflyerID <- map["appsflyerID"]
        ipAddress <- map["ipAddress"]
    }
}

class CheckAccountBeforeRegisterResponse: NSObject, Mappable {
    
    @objc dynamic var accountType:Int=0
    @objc dynamic var desc: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        accountType <- (map["Data.AccountType"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        desc <- map["Data.Description"]
    }
    
    func getAccountType() -> registerAccountType {
        switch accountType {
        case 1:
            return .type1
        case 2:
            return .type2
        case 3:
            return .type3
        default:
            return .type0
        }
    }
    
    enum registerAccountType:Int {
        case type0 = 0
        case type1 = 1
        case type2 = 2
        case type3 = 3
    }
}

/////////////////////

class LinkwithFacebookRequest: NSObject, Mappable {
    
    var email = ""
    var password = ""
    var deviceID = ""
    var deviceType = ""
    var fbToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, password:String, fbToken: String) {
        
        self.email = email
        self.password = password
        self.fbToken = fbToken
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        fbToken <- map["Account_Type_ID"]
        password <- map["Password"]
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        languageID <- map["LanguageID"]

    }
}


/////////////////////

class ResetPasswordRequest: NSObject, Mappable {
    
    var email = ""
    var currentPassword = ""
    var password = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(email: String, currentPassword:String, password:String, accessToken: String) {
        
        self.email = email
        self.currentPassword = currentPassword
        self.password = password
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        currentPassword <- map["CurrentPassword"]
        password <- map["Password"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

//////

class UpdateDeviceInfoRequest: NSObject, Mappable {
    
    var deviceID = ""
    var deviceType = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(accessToken: String) {
        
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}
