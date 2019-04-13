//
//  PolicyData.swift
//  Plano
//
//  Created by Thiha Aung on 6/22/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class Policies : Object{
    
    @objc dynamic var aboutPlano = ""
    @objc dynamic var termsAndCondition = ""
    @objc dynamic var pdpa = ""
    @objc dynamic var privacypolicy = ""
    
    static func getPolicies() -> Policies {
        let realm = try! Realm()
        return realm.objects(Policies.self).first!
    }
}

class GetPolicyResponse : NSObject, Mappable{
    var aboutPlano : String?
    var termsAndConditions : String?
    var pdpa : String?
    var privacypolicy : String?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        aboutPlano <- map["Data.About.Content"]
        termsAndConditions <- map["Data.TermAndCondition.Content"]
        pdpa <- map["Data.PersonalDataProtectionAct.Content"]
        privacypolicy <- map["Data.PrivacyPolicy.Content"]
    }
}

class GetPolicyRequest : NSObject, Mappable{
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
