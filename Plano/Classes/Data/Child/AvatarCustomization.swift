//
//  AvatarCustomization.swift
//  Plano
//
//  Created by Paing Pyi on 31/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//


import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class AvatarItemsRequest : NSObject, Mappable{
    var childID : String?
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : String, accessToken : String) {
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}


class AvatarItem: Object, Mappable {
    
    @objc dynamic var gameItemID = ""
    @objc dynamic var name = ""
    @objc dynamic var neededPoint:Int = 0
    @objc dynamic var image = ""
    @objc dynamic var thumbnail = ""
    @objc dynamic var itemPlace = ""
    @objc dynamic var itemCategory = ""
    @objc dynamic var active:Bool = false
    @objc dynamic var bought:Bool = false
    
    required convenience init?(map: Map){
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "gameItemID"
    }
    
    func mapping(map: Map) {
        
        gameItemID <- map["GameItemID"]
        name <- map["Name"]
        neededPoint <- (map["NeededPoint"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        image <- map["Item_Image"]
        thumbnail <- map["Item_Thumbnail"]
        itemPlace <- map["ItemPlace"]
        itemCategory <- map["ItemCategory"]
        active <- (map["ActiveItem"], TransformOf<Bool, String>(fromJSON: { String($0!)?.toBool() }, toJSON: { $0.map { String($0) } }))
        bought <- (map["BoughtItem"], TransformOf<Bool, String>(fromJSON: { String($0!)?.toBool() }, toJSON: { $0.map { String($0) } }))

    }
    
    func isHat() -> Bool {
        return self.itemCategory == "Hat"
    }
    func isBadge() -> Bool {
        return self.itemCategory == "Badge"
    }
    func isGlasses() -> Bool {
        return self.itemCategory == "Glasses"
    }
}


class AvatarItemResponse : NSObject, Mappable{
    
    var items:[AvatarItem] = [AvatarItem]()
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        items <- map["Data.listChildItems"]
    }
}

class AddNewGameItemRequest : NSObject, Mappable{
    var childID = ""
    var accessToken = ""
    var gameItemID = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : String, accessToken : String, gameItemID : String) {
        self.childID = childID
        self.accessToken = accessToken
        self.gameItemID = gameItemID
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        gameItemID <- map["GameItemID"]
        languageID <- map["LanguageID"]

    }
}
class AddNewGameItemResponse : NSObject, Mappable{
    
    var points:String = ""
    
    required init?(map: Map){
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        points <- map["Data.Points"]
    }
}

class GameItemStatusRequest : NSObject, Mappable{
    var childID = ""
    var accessToken = ""
    var gameItemID = ""
    var status = "" // 1
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(childID : String, accessToken : String, gameItemID : String) {
        self.childID = childID
        self.accessToken = accessToken
        self.gameItemID = gameItemID
        self.status = "1"
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        gameItemID <- map["GameItemID"]
        status <- map["Status"]
        languageID <- map["LanguageID"]

    }
}
