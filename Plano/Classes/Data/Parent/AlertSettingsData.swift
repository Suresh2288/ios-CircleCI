//
//  AlertSettingsData.swift
//  Plano
//
//  Created by Thiha Aung on 6/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class AlertSettings : Object,Mappable{
    
    @objc dynamic var alertID : Int = 0
    @objc dynamic var titleText = ""
    @objc dynamic var descriptionText = ""
    @objc dynamic var allowPush = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        alertID <- (map["AlertID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        titleText <- map["Title"]
        descriptionText <- map["Description"]
        allowPush <- map["AllowPush"]
    }
    
    static func getSettings() -> Results<AlertSettings>{
        let realm = try! Realm()
        return realm.objects(AlertSettings.self)
    }
    
    static func getSettingByAlertID(alertID : Int) -> Results<AlertSettings>?{
        let realm = try! Realm()
        let predicate = NSPredicate(format: "alertID == \(alertID)")
        return realm.objects(AlertSettings.self).filter(predicate)
    }
    
}

class AlertSettingsResponse : NSObject,Mappable{
    
    @objc dynamic var alertSettings : [AlertSettings]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        alertSettings <- map["Data.ListAlerts"]
    }
}

class AlertSettingsRequest : NSObject,Mappable{
    
    var email : String = ""
    var accessToken : String = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String){
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class UpdateAlertSettingsRequest : NSObject,Mappable{
    
    var email : String = ""
    var accessToken : String = ""
    var alertID : Int?
    var allowPush : Bool?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, alertID : Int, allowPush : Bool){
        self.email = email
        self.accessToken = accessToken
        self.alertID = alertID
        self.allowPush = allowPush
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        alertID <- map["AlertID"]
        allowPush <- map["AllowPush"]
        languageID <- map["LanguageID"]

    }
}

