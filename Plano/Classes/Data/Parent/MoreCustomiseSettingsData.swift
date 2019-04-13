//
//  MoreCustomiseSettingsData.swift
//  Plano
//
//  Created by Thiha Aung on 6/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RealmSwift
import ObjectMapper

class CustomiseSettings : Object, Mappable{
    
    @objc dynamic var custSettingID = ""
    @objc dynamic var scheduleActive = ""
    @objc dynamic var locationActive = ""
    @objc dynamic var contentActive = ""
    @objc dynamic var blueFilterScreen = ""
    @objc dynamic var blueFilterMode = ""
    @objc dynamic var blockAppActive = ""
    @objc dynamic var blockBrowserActive = ""
    @objc dynamic var contentID = ""
    @objc dynamic var childRating = ""
    @objc dynamic var posture:String?
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        custSettingID <- map["CustSettingID"]
        scheduleActive <- map["ScheduleActive"]
        locationActive <- map["LocationActive"]
        contentActive <- map["ContentActive"]
        blueFilterScreen <- map["BlueFilterScreen"]
        blueFilterMode <- map["BlueFilterMode"]
        blockAppActive <- map["BlockAppActive"]
        blockBrowserActive <- map["BlockBrowserActive"]
        contentID <- map["ContentID"]
        childRating <- map["ChildRating"]
        posture <- map["Posture"]
    }
    
    static func getCustomiseSettingsObj() -> CustomiseSettings? {
        let realm = try! Realm()
        return realm.objects(CustomiseSettings.self).first
    }

    func isLocationOptionActive() -> Bool {
        if let active = self.locationActive.toBool() {
            return active
        }else{
            return false
        }
    }
    
    func shouldCalibratePosture() -> Bool {
        if let post = self.posture {
            return post.toBool()!
        }
        return false
    }

}

class LocationSettingsData : Object,Mappable{
    
    @objc dynamic var locationeID : Int = 0
    @objc dynamic var descriptionText = ""
    @objc dynamic var latitude = ""
    @objc dynamic var longitude = ""
    @objc dynamic var zoomsize = ""
    @objc dynamic var placeID = ""
    @objc dynamic var addressTitle = ""
    @objc dynamic var address = ""
    @objc dynamic var active = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        locationeID <- (map["LocationeID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        descriptionText <- map["Description"]
        latitude <- map["Latitude"]
        longitude <- map["Longitude"]
        zoomsize <- map["Zoomsize"]
        placeID <- map["PlaceID"]
        addressTitle <- map["AddressTitle"]
        address <- map["Address"]
        active <- map["Active"]
    }
    
    static func getAllLocationSettings() -> Results<LocationSettingsData> {
        let realm = try! Realm()
        return realm.objects(LocationSettingsData.self)
    }
    static func getAllActiveLocationSettings() -> Results<LocationSettingsData> {
        let realm = try! Realm()
        return realm.objects(LocationSettingsData.self).filter("active == 'True'")
    }
    static func getLocationByID(locationID : Int) -> LocationSettingsData? {
        let realm = try! Realm()
        return realm.objects(LocationSettingsData.self).filter(("locationeID = \(locationID)")).first
        
    }
}



class ScheduleSettingsData : Object,Mappable{
    
    @objc dynamic var scheduleID : Int = 0
    @objc dynamic var titleText = ""
    @objc dynamic var fromTime = ""
    @objc dynamic var toTime = ""
    @objc dynamic var active = ""
    @objc dynamic var schedulePeriod = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        scheduleID <- (map["ScheduleID"], TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } }))
        titleText <- map["Title"]
        fromTime <- map["FromTime"]
        toTime <- map["ToTime"]
        active <- map["Active"]
        schedulePeriod <- map["SchedulePeriod"]
    }
    
    static func getAllScheduleSettings() -> Results<ScheduleSettingsData> {
        let realm = try! Realm()
        return realm.objects(ScheduleSettingsData.self)
    }
    
    static func getScheduleByID(scheduleID : Int) -> ScheduleSettingsData? {
        let realm = try! Realm()
        return realm.objects(ScheduleSettingsData.self).filter(("scheduleID = \(scheduleID)")).first
    }
    
}


class MoreCustomiseSettingsResponse : NSObject, Mappable{
    var customiseSettings : CustomiseSettings?
    var locationSettings : [LocationSettingsData]?
    var scheduleSettingsData : [ScheduleSettingsData]?
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        customiseSettings <- map["Data"]
        locationSettings <- map["Data.Locations"]
        scheduleSettingsData <- map["Data.Schedules"]
    }
}

class MoreCustomiseSettingsRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var identifierForVendor = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, identifierForVendor:String) {
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.identifierForVendor = identifierForVendor
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        identifierForVendor <- map["IdentifierForVendor"]
        languageID <- map["LanguageID"]

    }
}

class CreateScheduleRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var schedulePeriod = ""
    var title = ""
    var fromTime = ""
    var toTime = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, schedulePeriod : String, title :String, fromTime : String, toTime : String) {
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.schedulePeriod = schedulePeriod
        self.title = title
        self.fromTime = fromTime
        self.toTime = toTime
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        schedulePeriod <- map["SchedulePeriod"]
        title <- map["Title"]
        fromTime <- map["FromTime"]
        toTime <- map["ToTime"]
        languageID <- map["LanguageID"]

    }
}

class DeleteScheduleRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var scheduleID : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, scheduleID : Int) {
        self.email = email
        self.accessToken = accessToken
        self.scheduleID = scheduleID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        scheduleID <- map["ScheduleID"]
        languageID <- map["LanguageID"]

    }
}

class CreateLocationRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var descriptionTitle = ""
    var latitude : Double?
    var longitude : Double?
    var placeID = ""
    var address = ""
    var addressTitle = ""
    var zoomsize : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, descriptionTitle : String, latitude : Double, longitude : Double, placeID : String, address : String, addressTitle : String, zoomsize : Int){
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.descriptionTitle = descriptionTitle
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.address = address
        self.addressTitle = addressTitle
        self.zoomsize = zoomsize
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        descriptionTitle <- map["Description"]
        latitude <- map["Latitude"]
        longitude <- map["Longitude"]
        placeID <- map["PlaceID"]
        address <- map["Address"]
        addressTitle <- map["AddressTitle"]
        zoomsize <- map["Zoomsize"]
        languageID <- map["LanguageID"]

    }
}

class DeleteLocationRequest : NSObject, Mappable{
    var email = ""
    var accessToken = ""
    var locationID : Int?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, accessToken : String, locationID : Int) {
        self.email = email
        self.accessToken = accessToken
        self.locationID = locationID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        locationID <- map["LocationID"]
        languageID <- map["LanguageID"]

    }
}

class UpdatedSchedulesList : Object, Mappable{
    
    @objc dynamic var ScheduleID : Int = 0
    @objc dynamic var Active : Int = 0

    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {        
        if map.mappingType == .toJSON {
            ScheduleID >>> map["ScheduleID"]
            Active >>> map["Active"]
        }else{
            ScheduleID <- map["ScheduleID"]
            Active <- map["Active"]
        }
    }
    
    static func getSchedulesList() -> Results<UpdatedSchedulesList> {
        let realm = try! Realm()
        return realm.objects(UpdatedSchedulesList.self)
    }
    
    static func getScheduleObjByID(scheduleID : Int) -> UpdatedSchedulesList? {
        let realm = try! Realm()
        return realm.objects(UpdatedSchedulesList.self).filter(("ScheduleID = \(scheduleID)")).first
    }
    
    static func updateScheduleID(scheduleID : Int, active : Int){
        let realm = try! Realm()
        if let schedule = realm.objects(UpdatedSchedulesList.self).filter(("ScheduleID = \(scheduleID)")).first {
            try! realm.write {
                schedule.setValue(active, forKeyPath: "Active")
            }
        }
    }
    
    static func getUpdatedSchedules() -> [UpdatedSchedulesList] {
        let realm = try! Realm()
        return realm.objects(UpdatedSchedulesList.self).toArray()
    }
    
    static func getActiveScheduleList(active : Int) -> Results<UpdatedSchedulesList>? {
        let realm = try! Realm()
        return realm.objects(UpdatedSchedulesList.self).filter(("Active == \(active)"))
    }
    
}


class UpdatedLocationsList : Object, Mappable{
    
    @objc dynamic var LocationID : Int = 0
    @objc dynamic var Active : Int = 0
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        if map.mappingType == .toJSON {
            LocationID >>> map["LocationID"]
            Active >>> map["Active"]
        }else{
            LocationID <- map["LocationID"]
            Active <- map["Active"]
        }
    }
    
    static func getLocationsList() -> Results<UpdatedLocationsList> {
        let realm = try! Realm()
        return realm.objects(UpdatedLocationsList.self)
    }
    
    static func getLocationObjByID(locationID : Int) -> UpdatedLocationsList? {
        let realm = try! Realm()
        return realm.objects(UpdatedLocationsList.self).filter(("LocationID = \(locationID)")).first
    }
    
    static func updateLocationID(locationID : Int, active : Int){
        let realm = try! Realm()
        if let schedule = realm.objects(UpdatedLocationsList.self).filter(("LocationID = \(locationID)")).first{
            try! realm.write {
                schedule.setValue(active, forKeyPath: "Active")
            }
        }
    }
    
    static func getUpdatedLocations() -> [UpdatedLocationsList] {
        let realm = try! Realm()
        return realm.objects(UpdatedLocationsList.self).toArray()
    }
    
    static func getActiveLocationList(active : Int) -> Results<UpdatedLocationsList>? {
        let realm = try! Realm()
        return realm.objects(UpdatedLocationsList.self).filter(("Active == \(active)"))
    }
    
}


class UpdateCustomiseSettingsRequest : NSObject, Mappable{
    var email = ""
    var childID : Int?
    var accessToken = ""
    var scheduleActive : Int?
    var blockAppActive : Int?
    var locationActive : Int?
    var weeklyReportActive : Int?
    var monthlyReportActive : Int?
    var locationList : [UpdatedLocationsList]?
    var scheduleList : [UpdatedSchedulesList]?
    var ratingApp : Int?
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, childID : Int, accessToken : String, scheduleActive : Int, blockAppActive : Int, locationActive : Int, weeklyReportActive : Int, monthlyReportActive : Int, locationList : [UpdatedLocationsList], scheduleList : [UpdatedSchedulesList], ratingApp : Int){
        self.email = email
        self.childID = childID
        self.accessToken = accessToken
        self.scheduleActive = scheduleActive
        self.blockAppActive = blockAppActive
        self.locationActive = locationActive
        self.weeklyReportActive = weeklyReportActive
        self.monthlyReportActive = monthlyReportActive
        self.locationList = locationList
        self.scheduleList = scheduleList
        self.ratingApp = ratingApp
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        scheduleActive <- map["ScheduleActive"]
        blockAppActive <- map["BlockAppActive"]
        locationActive <- map["LocationActive"]
        weeklyReportActive <- map["WeeklyReportActive"]
        monthlyReportActive <- map["MonthlyReportActive"]
        locationList <- map["LocationList"]
        scheduleList <- map["ScheduleList"]
        ratingApp <- map["ratingApp"]
    }
}

class UpdateScheduleRequest : NSObject, Mappable{
    var email = ""
    var scheduleID : Int?
    var accessToken = ""
    var schedulePeriod = ""
    var title = ""
    var fromTime = ""
    var toTime = ""
    
    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, scheduleID : Int, accessToken : String, schedulePeriod : String, title :String, fromTime : String, toTime : String) {
        self.email = email
        self.scheduleID = scheduleID
        self.accessToken = accessToken
        self.schedulePeriod = schedulePeriod
        self.title = title
        self.fromTime = fromTime
        self.toTime = toTime
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        scheduleID <- map["ScheduleID"]
        accessToken <- map["Access_Token"]
        schedulePeriod <- map["SchedulePeriod"]
        title <- map["Title"]
        fromTime <- map["FromTime"]
        toTime <- map["ToTime"]
    }
}

class UpdateLocationRequest : NSObject, Mappable{
    var email = ""
    var locationID : Int?
    var accessToken = ""
    var descriptionTitle = ""
    var latitude : Double?
    var longitude : Double?
    var placeID = ""
    var address = ""
    var addressTitle = ""
    var zoomsize : Int?
    var active : Bool?
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, locationID : Int, accessToken : String, descriptionTitle : String, latitude : Double, longitude : Double, placeID : String, address : String, addressTitle : String, zoomsize : Int, active : Bool){
        self.email = email
        self.locationID = locationID
        self.accessToken = accessToken
        self.descriptionTitle = descriptionTitle
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.address = address
        self.addressTitle = addressTitle
        self.zoomsize = zoomsize
        self.active = active
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        locationID <- map["LocationID"]
        accessToken <- map["Access_Token"]
        descriptionTitle <- map["Description"]
        latitude <- map["Latitude"]
        longitude <- map["Longitude"]
        placeID <- map["PlaceID"]
        address <- map["Address"]
        addressTitle <- map["AddressTitle"]
        zoomsize <- map["Zoomsize"]
        active <- map["Active"]
        languageID <- map["LanguageID"]

    }

}

class UpdateBlockSubScheduleRequest : NSObject, Mappable{
    var email = ""
    var scheduleID = ""
    var accessToken = ""
    var scheduleActive = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, scheduleID : String, accessToken : String, scheduleActive : String){
        self.email = email
        self.scheduleID = scheduleID
        self.accessToken = accessToken
        self.scheduleActive = scheduleActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        scheduleID <- map["ScheduleID"]
        accessToken <- map["Access_Token"]
        scheduleActive <- map["ScheduleActive"]
        languageID <- map["LanguageID"]

    }
    
}

class UpdateBlockAppiOSRequest : NSObject, Mappable{
    var email = ""
    var appRating = ""
    var accessToken = ""
    var childID = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, appRating : String, accessToken : String, childID : String){
        self.email = email
        self.appRating = appRating
        self.accessToken = accessToken
        self.childID = childID
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        appRating <- map["AppRating"]
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        languageID <- map["LanguageID"]

    }
    
}

class UpdateBlockSubLocationRequest : NSObject, Mappable{
    var email = ""
    var locationID = ""
    var accessToken = ""
    var locationActive = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map) {
        
    }
    
    override init(){
        super.init()
    }
    
    init(email : String, locationID : String, accessToken : String, locationActive : String){
        self.email = email
        self.locationID = locationID
        self.accessToken = accessToken
        self.locationActive = locationActive
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        locationID <- map["LocationID"]
        accessToken <- map["Access_Token"]
        locationActive <- map["LocationActive"]
        languageID <- map["LanguageID"]

    }
    
}

