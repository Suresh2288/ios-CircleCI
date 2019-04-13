//
//  CityData.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class CityDataList: NSObject, Mappable {
    
    @objc dynamic var cities: [CityData]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        cities <- map["Data.cities"]
    }
    
}

class CityData: Object, Mappable {
    
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    static func getAllObjects() -> Results<CityData> {
        let realm = try! Realm()
        return realm.objects(CityData.self)
    }
    
    static func getCityByID(cid:String) -> CityData? {
        return CityData.getAllObjects().filter("id = '\(cid)'").first
    }
    
    static func getBySearchText(searchText : String) -> Results<CityData> {
        let predicate = NSPredicate(format: "name BEGINSWITH[cd] %@", searchText)
        return CityData.getAllObjects().filter(predicate)
    }
}
