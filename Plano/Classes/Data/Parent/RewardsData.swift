//
//  RewardsData.swift
//  Plano
//
//  Created by Thiha Aung on 6/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//


import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class TotalPoints : Object, Mappable{
    
    @objc dynamic var totalPoints = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        totalPoints <- map["totalpoints"]
    }
    
    static func getTotalPoints() -> TotalPoints? {
        let realm = try! Realm()
        return realm.objects(TotalPoints.self).first!
    }
}

class WishList : Object, Mappable{
    
    @objc dynamic var productID : Int = 0
    @objc dynamic var productName = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var productImage = ""
    @objc dynamic var expiry : Date?
    @objc dynamic var serverDate : Date?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        productID <- (map["ProductID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productName <- map["ProductName"]
        categoryName <- map["CategoryName"]
        productImage <- map["ProductImage"]
        expiry <- (map["Expiry"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        serverDate <- (map["ServerDate"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
    }
    
    static func getWishList() -> Results<WishList> {
        let realm = try! Realm()
        return realm.objects(WishList.self)
    }
    
}

class SuggestedList : Object, Mappable{
    
    @objc dynamic var productID : Int = 0
    @objc dynamic var productName = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var productImage = ""
    @objc dynamic var expiry : Date?
    @objc dynamic var serverDate : Date?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        productID <- (map["ProductID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productName <- map["ProductName"]
        categoryName <- map["CategoryName"]
        productImage <- map["ProductImage"]
        expiry <- (map["Expiry"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        serverDate <- (map["ServerDate"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
    }
    
    static func getSuggestedList() -> Results<SuggestedList> {
        let realm = try! Realm()
        return realm.objects(SuggestedList.self)
    }
    
}

class GetRewardsResponse : NSObject, Mappable{
    
    var totalPoints : TotalPoints?
    var wishList : [WishList]?
    var suggestedList : [SuggestedList]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        totalPoints <- map["Data"]
        wishList <- map["Data.wishlist"]
        suggestedList <- map["Data.listsuggested"]
    }
}

class GetRewardsRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String) {
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}
