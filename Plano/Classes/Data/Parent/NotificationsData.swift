//
//  NotificationsData.swift
//  Plano
//
//  Created by Thiha Aung on 6/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class NotificationsList : Object, Mappable{
    
    @objc dynamic var pushID = ""
    @objc dynamic var type = ""
    @objc dynamic var title = ""
    @objc dynamic var message = ""
    @objc dynamic var name = ""
    @objc dynamic var packageName = ""
    @objc dynamic var email = ""
    @objc dynamic var childID = ""
    @objc dynamic var sound = ""
    @objc dynamic var priority = ""
    @objc dynamic var seen = ""
    @objc dynamic var isMarked : String?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        pushID <- map["pushid"]
        type <- map["type"]
        title <- map["title"]
        message <- map["message"]
        name <- map["name"]
        packageName <- map["packagename"]
        email <- map["email"]
        childID <- map["childid"]
        sound <- map["sound"]
        priority <- map["priority"]
        seen <- map["seen"]
    }
    
    override static func primaryKey() -> String? {
        return "pushID"
    }
    
    static func getNotificationsList() -> Results<NotificationsList> {
        let realm = try! Realm()
        return realm.objects(NotificationsList.self)
    }
    
    static func getUnMarkedNotificationList() -> Results<NotificationsList>{
        let realm = try! Realm()
        return realm.objects(NotificationsList.self).filter("isMarked != 'true'")
    }
    
    static func getMarkedNotificationList() -> Results<NotificationsList>{
        let realm = try! Realm()
        return realm.objects(NotificationsList.self).filter("isMarked == 'true'")
    }
    
    static func updateNotificationLocally(){
        let realm = try! Realm()
        let notification = realm.objects(NotificationsList.self)
        try! realm.write {
            notification.setValue("true", forKeyPath: "isMarked")
        }
    }
    
    static func clearNotificationData() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(NotificationsList.self))
        }
    }
    
}

class GetNotificationsResponse : NSObject, Mappable{
    var notificationsList : [NotificationsList]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        notificationsList <- map["Data.listnotification"]
    }
}

class GetNotificationsRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String) {
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

class UpdateNotiSeenRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var notiIDList : [Int] = []
    var seen = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, notiIDList : [Int], seen : String) {
        self.email = email
        self.accessToken = accessToken
        self.notiIDList = notiIDList
        self.seen = seen
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        notiIDList <- map["ArrayNotiID"]
        seen <- map["Seen"]
        languageID <- map["LanguageID"]

    }
}
