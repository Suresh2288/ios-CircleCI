//
//  CountryData.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class CountryDataList: NSObject, Mappable {
    
    @objc dynamic var countries: [CountryData]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        countries <- map["Data.countries"]
    }
    
}

class CountryData: Object, Mappable {
    
    @objc dynamic var id = ""
    @objc dynamic var name = ""

    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    
    static func getAllObjects() -> Results<CountryData> {
        let realm = try! Realm()
        return realm.objects(CountryData.self)
    }
    
    static func getCountryByID(cid:String) -> CountryData? {
        return CountryData.getAllObjects().filter("id = '\(cid)'").first
    }

    static func getBySearchText(searchText : String) -> Results<CountryData> {
        let predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
        return CountryData.getAllObjects().filter(predicate)
    }
}

class CityDataRequest: NSObject, Mappable {
    
    var sortname = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(sortname:String) {
        self.sortname = sortname
    }
    
    func mapping(map: Map) {
        sortname <- map["sortname"]
        languageID <- map["LanguageID"]

    }
}

