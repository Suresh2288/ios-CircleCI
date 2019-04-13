//
//  ProfileData.swift
//  Plano
//
//  Created by Paing Pyi on 17/1/18.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper

class ChildProfileStatusRequest: NSObject, Mappable {
    
    @objc dynamic var email = ""
    @objc dynamic var childID:Int = 0
    @objc dynamic var accessToken = ""
    @objc dynamic var status:Int = 0 // default 0 as "delete account"
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        status <- map["Status"]
        languageID <- map["LanguageID"]
    }
}

