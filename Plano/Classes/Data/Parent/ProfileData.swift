//
//  ProfileData.swift
//  Plano
//
//  Created by Paing Pyi on 29/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ProfileData: Object, Mappable {
    
    @objc dynamic var email = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var countryResidence:String?
    @objc dynamic var city:String?
    @objc dynamic var countryCode:String?
    @objc dynamic var mobile:String = ""
    @objc dynamic var profileImage:String?
    @objc dynamic var accessToken = ""
    @objc dynamic var premiumID:String?
    @objc dynamic var subscriptionEnabled:String?
    @objc dynamic var CountryRegistered:String?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        countryResidence <- map["Country_Residence"]
        city <- map["City"]
        countryCode <- map["Country_Code"]
        mobile <- map["Mobile"]
        profileImage <- map["Profile_Image"]
        accessToken <- map["Access_Token"]
        premiumID <- map["PremiumID"]
        subscriptionEnabled <- map["SubscriptionEnabled"]
        CountryRegistered <- map["Country_Registered"]
    }
    
    static func getProfileObj() -> ProfileData? {
        let realm = try! Realm()
        return realm.objects(ProfileData.self).first
    }
    
    static func updateAccessToken(token:String) {
        let realm = try! Realm()
        if let profile = self.getProfileObj() {
            try! realm.write {
                profile.accessToken = token
            }
        }
    }
    
    static func clearProfileData() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(ProfileData.self))
        }
    }
}

class UpdateProfileRequest: NSObject, Mappable {
    
    var accessToken = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var countryResidence:String?
    var city:String?
    var countryCode:String?
    var mobile:String = ""
    var profileImage:String?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        accessToken <- map["Access_Token"]
        email <- map["Email"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        countryResidence <- map["Country_Residence"]
        city <- map["City"]
        countryCode <- map["Country_Code"]
        mobile <- map["Mobile"]
        profileImage <- map["Profile_Image"]
        languageID <- map["LanguageID"]
    }
    
    
    
    
}

