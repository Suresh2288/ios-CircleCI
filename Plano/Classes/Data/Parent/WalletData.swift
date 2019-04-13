//
//  WalletData.swift
//  Plano
//
//  Created by Thiha Aung on 5/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ParentProductsBannerList : Object, Mappable{
    
    @objc dynamic var adID : Int = 0
    @objc dynamic var productImage = ""
    @objc dynamic var pruchaseLink = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        
        adID <- (map["AdID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productImage <- map["ProductImage"]
        pruchaseLink <- map["PruchaseLink"]
        
    }
    
    static func getBanner() -> ParentProductsBannerList?{
        let realm = try! Realm()
        if let obj = realm.objects(ParentProductsBannerList.self).first{
            return obj
        }else{
            return nil
        }
    }
    
}

class ParentProductsList : Object, Mappable{
    
    @objc dynamic var productID : Int = 0
    @objc dynamic var productName = ""
    @objc dynamic var productImage = ""
    @objc dynamic var categoryID = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var descriptionText = ""
    @objc dynamic var price : Double = 0.0
    @objc dynamic var brand = ""
    @objc dynamic var expiry : Date?
    @objc dynamic var serverDate : Date?
    @objc dynamic var isStar : Int = 0
    @objc dynamic var isRequested : String = ""
    @objc dynamic var cost : String = ""
    @objc dynamic var isCheckout : String = ""
    @objc dynamic var MerchantName : String = ""
    @objc dynamic var itemPrice : String = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        
        productID <- (map["ProductID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productName <- map["ProductName"]
        categoryID <- map["CategoryID"]
        categoryName <- map["CategoryName"]
        descriptionText <- map["Description"]
        expiry <- (map["Expiry"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        serverDate <- (map["ServerDate"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        price <- (map["Price"], TransformOf<Double, String>(fromJSON: { Double($0!) }, toJSON: { $0.map { String($0) } }))
        brand <- map["Brand"]
        productImage <- map["ProductImage"]
        isStar <- (map["IsStar"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        isRequested <- map["Requested"]
        cost <- map["Cost"]
        isCheckout <- map["IsCheckout"]
        MerchantName <- map["MerchantName"]
        itemPrice <- map["Price"]
    }
    
    static func getAllProducts() -> Results<ParentProductsList>{
        let realm = try! Realm()
        return realm.objects(ParentProductsList.self)
    }
    
    static func getChildRequestedProductWithSort(category: String,sort: String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if sort == "AEC"{
            if category == ""{
                return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: true)
            }
            return realm.objects(ParentProductsList.self).filter("isRequested = 'True'").sorted(byKeyPath: "productName",ascending: true)
        }else if sort == "DEC"{
            if category == ""{
                return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: false)
            }
            return realm.objects(ParentProductsList.self).filter("isRequested = 'True'").sorted(byKeyPath: "productName",ascending: false)
        }else{
            if category == ""{
                return realm.objects(ParentProductsList.self)
            }
            return realm.objects(ParentProductsList.self).filter("isRequested = 'True'")
        }
        
    }
    
    
    static func getAllProductsByCategoryID(category: String,sort: String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if sort == "AEC"{
            if category == ""{
                return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: true)
            }
            return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: true)
        }else if sort == "DEC"{
            if category == ""{
                return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: false)
            }
            return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: false)
        }else{
            if category == ""{
                return realm.objects(ParentProductsList.self)
            }
            return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'")
        }
        
    }
    
    static func getSortedAtoZProducts(category : String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: true)
        }
        return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: true)
    }
    
    static func getSortedZtoAProducts(category : String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ParentProductsList.self).sorted(byKeyPath: "productName",ascending: false)
        }
        return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: false)
    }
    
    static func getProductsCostHighToLow(category : String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ParentProductsList.self).sorted(byKeyPath: "price",ascending: false)
        }
        return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "price",ascending: false)
    }
    
    static func getProductsCostLowToHigh(category : String) -> Results<ParentProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ParentProductsList.self).sorted(byKeyPath: "price",ascending: true)
        }
        return realm.objects(ParentProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "price",ascending: true)
    }
}

class ParentProductsResponse : NSObject, Mappable{
    var productsBanner : ParentProductsBannerList?
    var products : [ParentProductsList]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        productsBanner <- map["Data.Banner"]
        products <- map["Data.listproduct"]
    }
}

class ParentProductsRequest : NSObject, Mappable{
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

class GetProductOrderRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var pageNo = ""
    var pageSize = "10"
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, pageNo : String) {
        self.email = email
        self.accessToken = accessToken
        self.pageNo = pageNo
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        pageSize <- map["pageSize"]
        pageNo <- map["pageNo"]
    }
}

class GetProductOrderDetailRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var orderUUID = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, orderUUID : String) {
        self.email = email
        self.accessToken = accessToken
        self.orderUUID = orderUUID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        orderUUID <- map["orderUUID"]
    }
}
