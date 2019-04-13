//
//  FAQData.swift
//  Plano
//
//  Created by Thiha Aung on 6/20/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class FAQs : Object, Mappable{
    
    @objc dynamic var questionID = ""
    @objc dynamic var question = ""
    @objc dynamic var answer = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        questionID <- map["QuestionID"]
        question <- map["Question"]
        answer <- map["Answer"]
    }
    
    static func getFAQs() -> Results<FAQs> {
        let realm = try! Realm()
        return realm.objects(FAQs.self)
    }
    
    static func getFAQBySearchText(searchText : String) -> Results<FAQs> {
        let subpredicates = ["question", "answer"].map { property in
            return NSPredicate(format: "%K CONTAINS[cd] %@", property, searchText)
        }
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
        let realm = try! Realm()
        return realm.objects(FAQs.self).filter(predicate)
    }
}

class GetFAQResponse : NSObject, Mappable{
    var faqs : [FAQs]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        faqs <- map["Data.listFAQs"]
    }
}

class GetFAQRequest : NSObject, Mappable{
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        languageID <- map["LanguageID"]
    }
}
