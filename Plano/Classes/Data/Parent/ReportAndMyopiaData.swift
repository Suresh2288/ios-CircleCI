//
//  ReportAndMyopiaData.swift
//  Plano
//
//  Created by Thiha Aung on 7/12/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwiftyUserDefaults

class ReportAndMyopiaData : Object,Mappable{
    
    @objc dynamic var weeklyReportActive = ""
    @objc dynamic var monthlyReportActive = ""
    @objc dynamic var myopiaDate = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        weeklyReportActive <- map["WeeklyReportActive"]
        monthlyReportActive <- map["MonthlyReportActive"]
        myopiaDate <- map["MyopiaDate"]
    }
    
    static func getReportsAndMyopia() -> ReportAndMyopiaData?{
        let realm = try! Realm()
        return realm.objects(ReportAndMyopiaData.self).first!
    }
    
}

class ReportAndMyopiaResponse : NSObject,Mappable{
    
    @objc dynamic var reportAndMyopiaData : ReportAndMyopiaData?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        reportAndMyopiaData <- map["Data"]
    }
}

class ReportAndMyopiaRequest : NSObject,Mappable{
    
    var email : String = ""
    var accessToken : String = ""
    var childID : Int = 0
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : Int){
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

class UpdateReports : NSObject,Mappable{
    
    var email : String = ""
    var accessToken : String = ""
    var childID : String = ""
    var weeklyReportActive : String = ""
    var monthlyReportActive : String = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, childID : String, weeklyReportActive : String, monthlyReportActive : String){
        self.email = email
        self.accessToken = accessToken
        self.childID = childID
        self.weeklyReportActive = weeklyReportActive
        self.monthlyReportActive = monthlyReportActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        weeklyReportActive <- map["WeeklyReportActive"]
        monthlyReportActive <- map["MonthlyReportActive"]
        languageID <- map["LanguageID"]

    }
}
