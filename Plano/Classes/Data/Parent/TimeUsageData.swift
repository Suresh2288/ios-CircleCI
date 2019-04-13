//
//  TimeUsageData.swift
//  Plano
//
//  Created by Thiha Aung on 5/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class TimeUsage : Object, Mappable{
    
    @objc dynamic var totalSecond = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        totalSecond <- map["TotalSecond"]
    }
    
    static func getTimeUsageObj() -> TimeUsage? {
        let realm = try! Realm()
        return realm.objects(TimeUsage.self).first!
    }
    
    static func clearTimeUsageObj() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(TimeUsage.self))
        }
    }
    
}

class TimeUsageResponse : NSObject, Mappable{
    var timeUsage : TimeUsage?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        timeUsage <- map["Data"]
    }
}

class TimeUsageRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var dateUsed = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, dateUsed : String) {
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.dateUsed = dateUsed
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        dateUsed <- map["DateUsed"]
        languageID <- map["LanguageID"]

    }
}
