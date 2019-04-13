//
//  FeedbackData.swift
//  Plano
//
//  Created by Thiha Aung on 6/25/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper

class UpdateFeedbackRequest : NSObject, Mappable{
    var email : String?
    var name : String?
    var categoryName : String?
    var descriptionText : String?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, name : String, categoryName : String, descriptionText : String) {
        self.email = email
        self.name = name
        self.categoryName = categoryName
        self.descriptionText = descriptionText
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        name <- map["Name"]
        categoryName <- map["CategoryName"]
        descriptionText <- map["Description"]
        languageID <- map["LanguageID"]

    }
}

