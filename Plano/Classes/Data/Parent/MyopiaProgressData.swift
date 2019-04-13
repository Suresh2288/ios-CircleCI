//
//  ParentData.swift
//  Plano
//
//  Created by Thiha Aung on 4/30/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

// MARK: Myopia -- Myopia Realm
class MyopiaProgressList: Object, Mappable{
    
    @objc dynamic var myopiaID = ""
    @objc dynamic var date = ""
    @objc dynamic var leftEye = ""
    @objc dynamic var rightEye = ""
    @objc dynamic var peroid = ""
    @objc dynamic var year = ""
    @objc dynamic var leftEyeValue = "0"
    @objc dynamic var rightEyeValue = "0"
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        myopiaID <- map["MyopiaID"]
        date <- map["Date"]
        leftEye <- map["Left_Eye"]
        rightEye <- map["Right_Eye"]
        peroid <- map["Peroid"]
        year <- map["Year"]
    }
    
    static func getNoOfMonthsLeftEyeIncluded(year : String) -> Results<MyopiaProgressList>{
        let realm = try! Realm()
        return realm.objects(MyopiaProgressList.self).filter("year = '\(year)' AND leftEyeValue <> '0'")
    }
    
    static func getNoOfMonthsRightEyeIncluded(year : String) -> Results<MyopiaProgressList>{
        let realm = try! Realm()
        return realm.objects(MyopiaProgressList.self).filter("year = '\(year)' AND rightEyeValue <> '0'")
    }
    
    static func getMyopiaProgressByYearWithSort(year : String) -> Results<MyopiaProgressList> {
        let realm = try! Realm()
        return realm.objects(MyopiaProgressList.self).filter("year = '\(year)'").sorted(byKeyPath: "peroid", ascending: true)
    }
}

class MyopiaProgressSummary : Object, Mappable{
    
    @objc dynamic var myopiaID = ""
    @objc dynamic var date = ""
    @objc dynamic var leftEye = ""
    @objc dynamic var rightEye = ""
    @objc dynamic var peroid = ""
    @objc dynamic var leftEyeValue = "0"
    @objc dynamic var rightEyeValue = "0"
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        myopiaID <- map["MyopiaID"]
        date <- map["Date"]
        leftEye <- map["Left_Eye"]
        rightEye <- map["Right_Eye"]
        peroid <- map["Peroid"]
    }
    
    static func getMyopiaProgressByYearWithSort() -> Results<MyopiaProgressSummary> {
        let realm = try! Realm()
        return realm.objects(MyopiaProgressSummary.self).sorted(byKeyPath: "peroid", ascending: true)
    }
}


// MARK: Myopia -- Response
class ListMyopia: NSObject, Mappable {
    
    @objc dynamic var myopiaProgressList: [MyopiaProgressList]?
    @objc dynamic var year: String = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {

        // get original values from JSON
        myopiaProgressList <- map["ListMyopia"]
        year <- map["Year"]
        
        // prepare to inject Year into `MyopiaProgressList`
        let transform = TransformOf<Array<MyopiaProgressList>, Array<MyopiaProgressList>>(fromJSON: { (value: Array<MyopiaProgressList>?) -> Array<MyopiaProgressList>? in
            
            // get copy of Array
            var objModified = self.myopiaProgressList
            
            // iterate throught each dictionary and inject Year
            for index in 0...(objModified?.count)!-1 {
                objModified?[index]["year"] = self.year
            }
            
            return objModified
            
        }, toJSON: { (value: Array<MyopiaProgressList>?) -> Array<MyopiaProgressList>? in
            // transform value from Int? to String?
            return value
        })
        
        // replace with modified list
        myopiaProgressList <- (map["ListMyopia"], transform)
        
    }
    
}

class MyopiaProgressSummaryResponse : NSObject, Mappable{
    
    @objc dynamic var listMyopia: [MyopiaProgressSummary]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        listMyopia <- map["Data.MyopiaProgress"]
    }
    
}

// MARK: Myopia -- Response
class MyopiaProgressResponse: NSObject, Mappable {
    
    @objc dynamic var listMyopia: [ListMyopia]?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        listMyopia <- map["Data.MyopiaProgress"]
    }
    
}

// MARK: Myopia -- Use for getting progress
class MyopiaProgressSummaryRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var childID : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email: String, accessToken: String, childID : Int) {
        
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
}

// MARK: Myopia -- Use for getting progress
class MyopiaProgressRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var fromYear : Int?
    var toYear : Int?
    var childID : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email: String, accessToken: String, fromYear : Int, toYear : Int, childID : Int) {
        
        self.email = email
        self.accessToken = accessToken
        self.fromYear = fromYear
        self.toYear = toYear
        self.childID = childID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        fromYear <- map["FromYear"]
        toYear <- map["ToYear"]
        childID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
}


// MARK: Myopia -- Use for updating
class MyopiaProgressData: NSObject, Mappable {
    
    var email = ""
    var childID : Int?
    var date = ""
    var leftEye = ""
    var rightEye = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email: String, accessToken: String, date : String, leftEye : String, rightEye : String, childID : Int) {
        
        self.email = email
        self.accessToken = accessToken
        self.date = date
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.childID = childID
        
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        date <- map["Date"]
        leftEye <- map["Left_Eye"]
        rightEye <- map["Right_Eye"]
        childID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
}

