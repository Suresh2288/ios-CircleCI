//
//  IAPData.swift
//  Plano
//
//  Created by Thiha Aung on 8/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//  This file is used for storing iAP StoreKit Products information

import Foundation
import RealmSwift
import ObjectMapper

class iAPList : Object{
    
    @objc dynamic var productTitle = ""
    @objc dynamic var productDescription = ""
    @objc dynamic var productPrice = ""
    
    static func getProductList() -> Results<iAPList> {
        let realm = try! Realm()
        return realm.objects(iAPList.self)
    }
    
}

class UpdatePremiumRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var appleReceiptPayload = ""
    var country = ""
    var appleSubscriptionCode = ""
    
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
        appleReceiptPayload <- map["appleReceiptPayload"]
        languageID <- map["LanguageID"]
        country <- map["country"]
        appleSubscriptionCode <- map["appleSubscriptionCode"]
    }
}

class GetSubscriptionRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var countryCode = ""
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, countryCode : String) {
        self.email = email
        self.accessToken = accessToken
        self.countryCode = countryCode
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        countryCode <- map["Country"]
    }
}
