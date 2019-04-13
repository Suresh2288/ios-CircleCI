//
//  MDMData.swift
//  Plano
//
//  Created by Paing Pyi on 7/10/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults


///// App Rating

class AppRatingRequest : NSObject, Mappable{
    
    @objc dynamic var Access_Token = ""
    @objc dynamic var Email = ""
    @objc dynamic var ChildID = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(accessToken : String, email : String, childID : String) {
        self.Access_Token = accessToken
        self.Email = email
        self.ChildID = childID
    }
    
    func mapping(map: Map) {
        Access_Token <- map["Access_Token"]
        Email <- map["Email"]
        ChildID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
    
    
}

class AppRatingResponse : NSObject, Mappable{
    
    var CurrentChildRating:String = ""
    var listnotification:[AppRatingMDM]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        CurrentChildRating <- map["Data.CurrentChildRating"]
        listnotification <- map["Data.listnotification"]
    }
    
    
}


class AppRatingMDM : Object, Mappable{
    
    @objc dynamic var RatingID:Int = 0
    @objc dynamic var RatingName:String = ""
    @objc dynamic var isSelected:Bool = false
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        RatingID <- (map["RatingID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        RatingName <- map["RatingName"]
    }
    
    static func getRatingObjByID(ratingID : Int) -> AppRatingMDM{
        let realm = try! Realm()
        return realm.objects(AppRatingMDM.self).filter("RatingID = \(ratingID)").first!
    }
    
}
