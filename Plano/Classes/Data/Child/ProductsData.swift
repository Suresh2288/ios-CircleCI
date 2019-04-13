//
//  ChildShopData.swift
//  Plano
//
//  Created by Thiha Aung on 5/27/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ChildProductsList : Object, Mappable{
    
    @objc dynamic var productID : Int = 0
    @objc dynamic var productName = ""
    @objc dynamic var productImage = ""
    @objc dynamic var productImage2 = ""
    @objc dynamic var productImage3 = ""
    @objc dynamic var categoryID = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var descriptionText = ""
    @objc dynamic var cost : Double = 0.0
    @objc dynamic var brand = ""
    @objc dynamic var expiry : Date?
    @objc dynamic var requestedProduct = ""
    @objc dynamic var serverDate : Date?
    @objc dynamic var MerchantName = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        productID <- (map["ProductID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productName <- map["ProductName"]
        productImage <- map["ProductImage"]
        productImage2 <- map["ProductImage_2"]
        productImage3 <- map["ProductImage_3"]
        categoryID <- map["CategoryID"]
        categoryName <- map["CategoryName"]
        descriptionText <- map["Description"]
        cost <- (map["Cost"], TransformOf<Double, String>(fromJSON: { Double($0!) }, toJSON: { $0.map { String($0) } }))
        brand <- map["Brand"]
        expiry <- (map["Expiry"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        requestedProduct <- map["RequestedProduct"]
        serverDate <- (map["ServerDate"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        MerchantName <- map["MerchantName"]
    }
    
    static func getAllProducts() -> Results<ChildProductsList>{
        let realm = try! Realm()
        return realm.objects(ChildProductsList.self)
    }
    
    static func getAllProductsByCategoryID(category: String,sort: String) -> Results<ChildProductsList>{
        let realm = try! Realm()
        if sort == "AEC"{
            if category == ""{
                return realm.objects(ChildProductsList.self).sorted(byKeyPath: "productName",ascending: true)
            }
            return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: true)
        }else if sort == "DEC"{
            if category == ""{
                return realm.objects(ChildProductsList.self).sorted(byKeyPath: "productName",ascending: false)
            }
            return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: false)
        }else{
            if category == ""{
                return realm.objects(ChildProductsList.self)
            }
            return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'")
        }
        
    }
    
    static func getSortedAtoZProducts(category : String) -> Results<ChildProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ChildProductsList.self).sorted(byKeyPath: "productName",ascending: true)
        }
        return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: true)
    }
    
    static func getSortedZtoAProducts(category : String) -> Results<ChildProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ChildProductsList.self).sorted(byKeyPath: "productName",ascending: false)
        }
        return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "productName",ascending: false)
    }
    
    static func getProductsCostHighToLow(category : String) -> Results<ChildProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ChildProductsList.self).sorted(byKeyPath: "cost",ascending: false)
        }
        return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "cost",ascending: false)
    }
    
    static func getProductsCostLowToHigh(category : String) -> Results<ChildProductsList>{
        let realm = try! Realm()
        if category == ""{
            return realm.objects(ChildProductsList.self).sorted(byKeyPath: "cost",ascending: true)
        }
        return realm.objects(ChildProductsList.self).filter("categoryID = '\(category)'").sorted(byKeyPath: "cost",ascending: true)
    }
    
    static func getRequestedStateByProductID(productID : Int) -> ChildProductsList{
        let realm = try! Realm()
        return realm.objects(ChildProductsList.self).filter("productID = \(productID)").first!
    }
    
}

class ChildProductsResponse : NSObject, Mappable{
    var products : [ChildProductsList]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        products <- map["Data.listproduct"]
    }
}

class ChildProductsRequest : NSObject, Mappable{
    var childID : Int?
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : Int, accessToken : String) {
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}
