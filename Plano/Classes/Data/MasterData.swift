//
//  MasterData.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import AppVersionMonitor


class UpdateLanguageRequest: NSObject, Mappable {
    
    var email = ""
    var deviceID = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
    }
    
    init(email: String, accessToken: String) {
        self.email = email
        self.accessToken = accessToken
        self.deviceID = Defaults[.pushToken]
    }
    
    func mapping(map: Map) {
        email <- map["Parent_Email"]
        accessToken <- map["Access_Token"]
        deviceID <- map["DeviceID"]
        languageID <- map["LanguageID"]
    }
}

class MasterDataRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(email: String?, accessToken: String?) {
        
        self.email = email!
        self.accessToken = accessToken!
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class MasterDataResponse: NSObject, Mappable {
    
    @objc dynamic var schoolGrade: [SchoolGrade]?
    @objc dynamic var listLanguages: [Listlanguages]?
    @objc dynamic var splashAdvertising: SplashAdvertising?
    @objc dynamic var listEyeDegrees: [ListEyeDegrees]?
    var currentPremiumID : String?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        schoolGrade <- map["Data.SchoolGrade"]
        listLanguages <- map["Data.Listlanguages"]
        splashAdvertising <- map["Data.SplashAdvertising"]
        listEyeDegrees <- map["Data.ListEyeDegrees"]
        currentPremiumID <- map["Data.CurrentPremiumID"]
    }
    
}

/////////

class SchoolGrade: Object, Mappable {
    
    @objc dynamic var gradeID:Int = 0
    @objc dynamic var desc = ""
 
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        gradeID <- (map["GradeID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        desc <- map["Description"]
    }
}

class Listlanguages: Object, Mappable {
    
    @objc dynamic var LanguageID = ""
    @objc dynamic var LanguageName = ""
    @objc dynamic var IsDefault:Bool = false
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        LanguageID <- map["LanguageID"]
        LanguageName <- map["LanguageName"]
        IsDefault <- (map["IsDefault"], TransformOf<Bool, String>(fromJSON: { String($0!)?.toBool() }, toJSON: { $0.map { String($0) } }))
    }
    static func getSettings() -> Results<Listlanguages>{
        let realm = try! Realm()
        return realm.objects(Listlanguages.self)
    }
}

class SplashAdvertising: Object, Mappable {
    
    @objc dynamic var AdID = ""
    @objc dynamic var ProductImage = ""
    @objc dynamic var PruchaseLink = ""

    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        AdID <- map["AdID"]
        ProductImage <- map["ProductImage"]
        PruchaseLink <- map["PruchaseLink"]
    }
}

/////////

class ListEyeDegrees: Object, Mappable {
    
    @objc dynamic var EyeDegreeID = ""
    @objc dynamic var EyeDegreeDescription = ""
    @objc dynamic var EyeDegreeValue = ""

    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        EyeDegreeID <- map["EyeDegreeID"]
        EyeDegreeDescription <- map["EyeDegreeDescription"]
        EyeDegreeValue <- map["EyeDegreeValue"]
    }
    
    static func getEyeDegreeValueById(_ eyeDegreeID:String) -> ListEyeDegrees? {
        let realm = try! Realm()
        return realm.objects(ListEyeDegrees.self).filter("EyeDegreeID = %@",eyeDegreeID).first
    }
}

//////

class VersionDataResponse: NSObject, Mappable {
    
    @objc dynamic var forceUpdate: ForceUpdate?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        forceUpdate <- map["Data.ForceUpdate"]
    }
    
}

class ForceUpdate: Object, Mappable {
    
    @objc dynamic var Force = ""
    @objc dynamic var iOSVersion = ""
    @objc dynamic var iOSAppLink = ""
    @objc dynamic var IsFlag = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        Force <- map["Force"]
        iOSVersion <- map["iOSVersion"]
        iOSAppLink <- map["iOSAppLink"]
        IsFlag <- map["IsFlag"]
    }
    
    func isForceUpdate() -> Bool {
        if !self.Force.isEmpty && self.Force.toBool() == true {
            return true
        }
        return false
    }
    
    func isFlagCheck() -> Bool {
        if !self.IsFlag.isEmpty && self.IsFlag.toBool() == true {
            return true
        }
        return false
    }
    
    static func getVersionObject() -> ForceUpdate? {
        let realm = try! Realm()
        return realm.objects(ForceUpdate.self).first
    }
    
    static func shouldForceUserToUpdate() -> Bool {
        if let obj = ForceUpdate.getVersionObject(), let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let isForceUpdate = obj.isForceUpdate()
            let serverVersion = obj.iOSVersion
            if isForceUpdate && AppVersion(serverVersion) > AppVersion(appVersion) {
                return true
            }
        }
        return false
    }
}

