//
//  LogOutData.swift
//  Plano
//
//  Created by Thiha Aung on 6/11/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class LogOutRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var deviceID = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email: String, accessToken: String) {
        
        self.email = email
        self.accessToken = accessToken
        self.deviceID = Defaults[.pushToken]
        
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        deviceID <- map["Device_ID"]
        languageID <- map["LanguageID"]

    }
}
