//
//  RegisterData.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyUserDefaults

class RegisterData: NSObject, Mappable {
    
    var deviceID = ""
    var deviceType = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var country = ""
    var city = ""
    var countryCode = ""
    var mobile = ""
    var password = ""
    var accountTypeID = ""
    var profileImage = ""
    var appFlyerId = ""
    var ipAddress = ""
    
    var profileUrl:String?
    var fbid:String?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, password: String, firstName: String,
         lastName: String, country: String, city: String,
         countryCode: String, mobile: String, accountTypeID: String,
         profileImage: String ) {
        
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.country = country
        self.city = city
        self.countryCode = countryCode
        self.mobile = mobile
        self.accountTypeID = accountTypeID
        self.profileImage = profileImage
        
        self.deviceType = Constants.API.DeviceType
        self.deviceID = Defaults[.pushToken]
        self.appFlyerId = Defaults[.appFlyerId]!
        self.ipAddress = Defaults[.ipAddress]!
    }
    
    func mapping(map: Map) {
        
        languageID <- map["LanguageID"]
        deviceID <- map["Device_ID"]
        deviceType <- map["Device_Type"]
        password <- map["Password"]
        email <- map["Email"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        country <- map["Country_Residence"]
        city <- map["City"]
        countryCode <- map["Country_Code"]
        mobile <- map["Mobile"]
        appFlyerId <- map["appsflyerID"]
        ipAddress <- map["ipAddress"]

        accountTypeID <- map["Account_Type_ID"]
        profileImage <- map["Profile_Image"]
    }
}

class RegisterDataResponse: NSObject, Mappable {
    
    @objc dynamic var profile: ProfileData?
    
    var InstalledProfile = ""
    var IsTrial = ""
    var EmailValidate = ""

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profile <- map["Data.profile"]
    }
    
}

class FacebookRegisterDataResponse: NSObject, Mappable {
    
    @objc dynamic var profile: ProfileData?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profile <- map["Data.Profile"]
    }
    
}
