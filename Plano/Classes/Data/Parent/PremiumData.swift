//
//  PremiumData.swift
//  Plano
//
//  Created by Thiha Aung on 6/22/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class PremiumList : Object, Mappable{
    
    @objc dynamic var premiumID = ""
    @objc dynamic var premiumTitle = ""
    @objc dynamic var subscribeFees = ""
    @objc dynamic var subscribeFeesType = ""
    @objc dynamic var currentSubscribe = ""
    @objc dynamic var numberofChildAccount = ""
    @objc dynamic var numberofParentAccount = ""
    @objc dynamic var blueFilter = ""
    @objc dynamic var eyeTracking = ""
    @objc dynamic var timeTracking = ""
    @objc dynamic var rewards = ""
    @objc dynamic var eyeProgressTracking = ""
    @objc dynamic var pushNoti = ""
    @objc dynamic var remoteLock = ""
    @objc dynamic var locationFilter = ""
    @objc dynamic var appBlock = ""
    @objc dynamic var posture = ""
    @objc dynamic var orderNo = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        premiumID <- map["PremiumID"]
        premiumTitle <- map["Title"]
        subscribeFees <- map["SubscribeFees"]
        subscribeFeesType <- map["SubscribeFeesType"]
        currentSubscribe <- map["CurrentSubscribe"]
        numberofChildAccount <- map["NumberofChildAccount"]
        numberofParentAccount <- map["NumberofParentAccount"]
        blueFilter <- map["BlueFilter"]
        eyeTracking <- map["EyeTracking"]
        timeTracking <- map["TimeTracking"]
        rewards <- map["Rewards"]
        eyeProgressTracking <- map["EyeProgressTracking"]
        pushNoti <- map["PushNoti"]
        remoteLock <- map["RemoteLock"]
        locationFilter <- map["LocationFilter"]
        appBlock <- map["AppBlock"]
        posture <- map["Posture"]
        orderNo <- map["OrderNo"]
    }
    
    static func getPremiumListByOrderNo(orderNo : String) -> PremiumList? {
        let realm = try! Realm()
        return realm.objects(PremiumList.self).filter("orderNo == '\(orderNo)'").first
    }
    
    static func getPremiumListByTitle(title : String) -> PremiumList? {
        let realm = try! Realm()
        return realm.objects(PremiumList.self).filter("premiumTitle == '\(title)'").first
    }
    
}

class GetAllPremiumResponse : NSObject, Mappable{
    var premiumList : [PremiumList]?
    var subscriptionEnabled : String?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        premiumList <- map["Data.listpremium"]
        subscriptionEnabled <- map["Data.SubscriptionEnabled"]
    }
}

class GetAllPremiumRequest : NSObject, Mappable{
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

class CurrentSubscriptionResponse: NSObject, Mappable {
    
    @objc dynamic var DateValue = ""
    @objc dynamic var ParentName = ""
    @objc dynamic var PlanoPremiumTitle = ""
    @objc dynamic var IsExpiryDateDisplay:Bool = false
    @objc dynamic var IsEnableSubscribe:Bool = false
    @objc dynamic var IsEnableSubscribePrompt:Bool = false
    @objc dynamic var SubscribePrompt = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        DateValue <- map["Data.DateValue"]
        ParentName <- map["Data.ParentName"]
        PlanoPremiumTitle <- map["Data.PlanoPremiumTitle"]
        IsExpiryDateDisplay <- map["Data.IsExpiryDateDisplay"]
        IsEnableSubscribe <- map["Data.IsEnableSubscribe"]
        IsEnableSubscribePrompt <- map["Data.IsEnableSubscribePrompt"]
        SubscribePrompt <- map["Data.SubscribePrompt"]
    }
    
}

class GetAvailablePremiumResponse : NSObject, Mappable{
    var AvailablePlans : [AvailablePlans]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        AvailablePlans <- map["Data.AvailablePlans"]
    }
}

class AvailablePlans : Object, Mappable{
    
    @objc dynamic var TitleKey = ""
    @objc dynamic var PlanoPremiumCode = ""
    
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        TitleKey <- map["TitleKey"]
        PlanoPremiumCode <- map["PlanoPremiumCode"]
    }
    
}


