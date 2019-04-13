//
//  ChildShopData.swift
//  Plano
//
//  Created by Thiha Aung on 5/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ChildProductDetail : Object, Mappable{
    
    @objc dynamic var productID : Int = 0
    @objc dynamic var productName = ""
    @objc dynamic var productImage = ""
    @objc dynamic var productImage2 = ""
    @objc dynamic var productImage3 = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var descriptionText = ""
    @objc dynamic var promoCode = ""
    @objc dynamic var price = ""
    @objc dynamic var brand = ""
    @objc dynamic var cost = ""
    @objc dynamic var purchaseLink = ""
    @objc dynamic var expiry : Date?
    @objc dynamic var serverDate : Date?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        productID <- (map["ProductID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        productName <- map["ProductName"]
        productImage <- map["ProductImage"]
        productImage2 <- map["ProductImage_2"]
        productImage3 <- map["ProductImage_3"]
        categoryName <- map["CategoryName"]
        descriptionText <- map["Description"]
        promoCode <- map["Promocode"]
        price <- map["Price"]
        brand <- map["Brand"]
        cost <- map["Cost"]
        purchaseLink <- map["Purchaselink"]
        expiry <- (map["Expiry"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
        serverDate <- (map["ServerDate"], CustomDateFormatTransform(formatString: "MM/dd/yyyy hh:mm:ss a"))
    }
    
    static func getProductDetailObj() -> ChildProductDetail? {
        let realm = try! Realm()
        return realm.objects(ChildProductDetail.self).first
    }
    
    func getProductImages() -> [String] {
        var arr:[String] = []
        if productImage.isEmpty == false {
            arr.append(productImage)
        }
        if productImage2.isEmpty == false {
            arr.append(productImage2)
        }
        if productImage3.isEmpty == false {
            arr.append(productImage3)
        }
        return arr
    }
}

class ChildProductDetailResponse : NSObject, Mappable{
    var detail : ChildProductDetail?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        detail <- map["Data.productdetail"]
    }
}

class ChildProductDetailRequest : NSObject, Mappable{
    var childID : Int?
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var productID : Int?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : Int, accessToken : String, languageID : String, productID : Int) {
        self.childID = childID
        self.accessToken = accessToken
        self.languageID = languageID
        self.productID = productID
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        productID <- map["ProductID"]
    }
}


class UpdateChildRequestProduct : NSObject, Mappable{
    var childID : Int?
    var accessToken = ""
    var productID : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : Int, accessToken : String, productID : Int) {
        self.childID = childID
        self.accessToken = accessToken
        self.productID = productID
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        productID <- map["ProductID"]
        languageID <- map["LanguageID"]

    }
}

class UpdateChildRequestProductResponse : NSObject, Mappable{
    var point : String?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        point <- map["Data.Point"]
    }
}
