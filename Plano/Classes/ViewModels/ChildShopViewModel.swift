//
//  ChildShopViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 5/29/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class ChildShopViewModel{
    
    var productID : Int?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var beforeRequestApiCall : (() -> Void)?
    var afterRequestApiCall : (() -> Void)?
    
    func getAllProductForChild(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let childProfile = ActiveChildProfile.getProfileObj(){
            
            let data = ChildProductsRequest()
            data.childID = Int(childProfile.childID)
            data.accessToken = Defaults[.childAccessToken]!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ChildShopApiManager.sharedInstance.getAllProductForChild(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ChildProductsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let products = response.products{
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(ChildProductsList.self))
                                    realm.add(products)
                                }
                                
                            }
                        }
                        success()
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    func getProductDetailForChild(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let childProfile = ActiveChildProfile.getProfileObj(){
            
            let data = ChildProductDetailRequest()
            data.childID = Int(childProfile.childID)
            data.accessToken = Defaults[.childAccessToken]!
            data.productID = productID
            
            if ReachabilityUtil.shareInstance.isOnline(){
            
                beforeApiCall?()
                
                ChildShopApiManager.sharedInstance.getProductDetailForChild(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ChildProductDetailResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let detail = response.detail{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ChildProductDetail.self))
                                    realm.add(detail)
                                }
                            }
                        }
                        
                        success()
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage())
                        
                    }
                })
            }
        }
    }
    
    func updateChildRequestProduct(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let childProfile = ActiveChildProfile.getProfileObj(){
            
            let data = UpdateChildRequestProduct()
            data.childID = Int(childProfile.childID)
            data.accessToken = Defaults[.childAccessToken]!
            data.productID = productID
            
            if ReachabilityUtil.shareInstance.isOnline(){
            
                beforeRequestApiCall?()
                
                ChildShopApiManager.sharedInstance.updateChildRequestProduct(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterRequestApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        if let response = Mapper<UpdateChildRequestProductResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            // store point from server
                            let realm = try! Realm()
                            try! realm.write {
                                if let point = response.point, !point.isEmpty {
                                    childProfile.gamePoint = point
                                }
                            }
                        }
                        
                        success(apiResponseHandler.message!)
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    func getAllCategories(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        let request = GetAllCategoriesRequest()
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?()
            
            APIManager.sharedInstance.getAllCategories(request) {[weak self](apiResponseHandler, error) in
                
                if apiResponseHandler.isSuccess() {
                    
                    if let response = Mapper<GetAllCategoriesResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let data = response.listcategories {
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(AllCategories.self)) // clear old one
                                realm.add(data) // add new one
                            }
                        }
                        
                    }
                    
                    success()
                    
                }else{
                    failure(apiResponseHandler.errorMessage())
                }
                
                
            }
            
        }
    }
    
}
