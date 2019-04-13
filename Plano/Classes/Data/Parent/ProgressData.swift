//
//  ProgressData.swift
//  Plano
//
//  Created by Thiha Aung on 5/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ChildProgress : Object, Mappable{
    
    @objc dynamic var todayProgress = ""
    @objc dynamic var overAllProgress = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        todayProgress <- map["TodayProgress"]
        overAllProgress <- map["OverAllProgress"]
    }
    
    static func getChildProgressObj() -> ChildProgress? {
        let realm = try! Realm()
        return realm.objects(ChildProgress.self).first!
    }
    
    static func clearChildProgressObj() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(ChildProgress.self))
        }
    }
}

class ProgressResponse : NSObject, Mappable{
    var progress : ChildProgress?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        progress <- map["Data"]
    }
}

class ProgressRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var progressDate = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, progressDate : String) {
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.progressDate = progressDate
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        progressDate <- map["ProgressDate"]
        languageID <- map["LanguageID"]

    }
}
