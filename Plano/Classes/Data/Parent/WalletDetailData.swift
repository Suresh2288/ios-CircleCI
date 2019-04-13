//
//  WalletDetailData.swift
//  Plano
//
//  Created by Thiha Aung on 5/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ParentProductDetail : Object, Mappable{
    
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
    
    static func getProductDetailObj() -> ParentProductDetail? {
        let realm = try! Realm()
        return realm.objects(ParentProductDetail.self).first
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

class ParentProductDetailResponse : NSObject, Mappable{
    var detail : ParentProductDetail?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        detail <- map["Data.productdetail"]
    }
}

class ParentProductDetailRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var productID : Int?
    var isStar : Int?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, productID : Int, isStar : Int) {
        self.email = email
        self.accessToken = accessToken
        self.productID = productID
        self.isStar = isStar
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        productID <- map["ProductID"]
        isStar <- map["IsStar"]
    }
}

class UpdatePurchaseProductResponse : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var productID : Int?
    var isStar : Int?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, productID : Int, isStar : Int) {
        self.email = email
        self.accessToken = accessToken
        self.productID = productID
        self.isStar = isStar
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        productID <- map["ProductID"]
        isStar <- map["IsStar"]
    }
}

class UpdatePurchaseProductRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var productID : Int?
    var isStar : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, productID : Int, isStar : Int) {
        self.email = email
        self.accessToken = accessToken
        self.productID = productID
        self.isStar = isStar
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        productID <- map["ProductID"]
        isStar <- map["IsStar"]
        languageID <- map["LanguageID"]

    }
}
