//
//  LinkedAccountsData.swift
//  Plano
//
//  Created by Htarwara6245 on 5/23/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class LinkedAccounts : Object, Mappable{
    
    @objc dynamic var email = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var profileImage = ""
    @objc dynamic var active = ""
    @objc dynamic var statusCode = ""
    @objc dynamic var status = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        profileImage <- map["Profile_Image"]
        active <- map["Active"]
        statusCode <- map["StatusCode"]
        status <- map["Status"]
        
    }
    
    static func getAccountsLinkToMyChild() -> Results<LinkedAccounts>{
        let realm = try! Realm()
        return realm.objects(LinkedAccounts.self).filter("statusCode = '2'")
    }
    
    static func getAccountsIAmLinkTo() -> Results<LinkedAccounts>{
        let realm = try! Realm()
        return realm.objects(LinkedAccounts.self).filter("statusCode = '1'")
    }
    
}

class PendingRequests : Object, Mappable{
    
    @objc dynamic var email = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var profileImage = ""
    @objc dynamic var active = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        
        email <- map["Email"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        profileImage <- map["Profile_Image"]
        active <- map["Active"]
        
    }
    
    static func getPendingRequest() -> Results<PendingRequests>{
        let realm = try! Realm()
        return realm.objects(PendingRequests.self).filter("active = 'Pending'")
    }
    
    static func getRequests() -> Results<PendingRequests>{
        let realm = try! Realm()
        return realm.objects(PendingRequests.self).filter("active = 'Request'")
    }
}

class GetLinkedAccountsResponse : NSObject, Mappable{
    var linkedAccounts : [LinkedAccounts]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        linkedAccounts <- map["Data.profile"]
    }
}

class GetLinkedAccountsRequest : NSObject, Mappable{
    var parent_email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, accessToken : String) {
        self.parent_email = parent_email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class GetPendingAccountsResponse : NSObject, Mappable{
    var pendingRequests : [PendingRequests]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        pendingRequests <- map["Data.profile"]
    }
}

class GetPendingAccountsRequest : NSObject, Mappable{
    var parent_email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, accessToken : String) {
        self.parent_email = parent_email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class UpdateLinkedAccount : NSObject, Mappable{
    var parent_email = ""
    var guardian_email = ""
    var statusCode = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, guardian_email : String, statusCode : String, accessToken : String) {
        self.parent_email = parent_email
        self.guardian_email = guardian_email
        self.statusCode = statusCode
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        guardian_email <- map["Guardian_Email"]
        statusCode <- map["StatusCode"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class RejectPendingAccountRequest : NSObject, Mappable{
    var parent_email = ""
    var guardian_email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, guardian_email : String, accessToken : String) {
        self.parent_email = parent_email
        self.guardian_email = guardian_email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        guardian_email <- map["Guardian_Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class CreateLinkAccountRequest : NSObject, Mappable{
    var parent_email = ""
    var guardian_email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, guardian_email : String, accessToken : String) {
        self.parent_email = parent_email
        self.guardian_email = guardian_email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        guardian_email <- map["Guardian_Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class UpdateRequestLink : NSObject, Mappable{
    var parent_email = ""
    var guardian_email = ""
    var accept : Int?
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(parent_email : String, guardian_email : String, accept : Int, accessToken : String) {
        self.parent_email = parent_email
        self.guardian_email = guardian_email
        self.accept = accept
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        parent_email <- map["Parent_Email"]
        guardian_email <- map["Guardian_Email"]
        accept <- map["Accept"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}
