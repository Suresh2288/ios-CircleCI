//
//  ParentWalletViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 5/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class ParentWalletViewModel{
    
    var isStar : Int?
    var productID : Int?
    
    var pageNumber : String?
    var orderID : String?
    var shareSecret : String?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var beforeRequestApiCall : (() -> Void)?
    var afterRequestApiCall : (() -> Void)?
    
    func getAllProductForParent(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = ParentProductsRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                ParentWalletApiManager.sharedInstance.getAllProductForParent(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ParentProductsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            let realm = try! Realm()
                            
                            if let banner = response.productsBanner{
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ParentProductsBannerList.self))
                                    realm.add(banner)
                                }
                                
                            }
                            if let products = response.products{
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ParentProductsList.self))
                                    realm.add(products)
                                }
                            }
                            
                            success()
                        }
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
    
    func getProductDetailForParent(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = ParentProductDetailRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.productID = productID
            data.isStar = isStar
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentWalletApiManager.sharedInstance.getProductDetailForParent(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<ParentProductDetailResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let detail = response.detail{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(ParentProductDetail.self))
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
    
    func updatePurchaseProduct(success: @escaping (_ message: String) -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdatePurchaseProductRequest()
            data.email = profile.email
            data.accessToken = profile.accessToken
            data.productID = productID
            data.isStar = isStar
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeRequestApiCall?()
                
                ParentWalletApiManager.sharedInstance.updatePurchaseProduct(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterRequestApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
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
    
    func getShopBanner(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getShopBanner() { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getFeaturedProducts(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getFeaturedProducts() { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getParentPaymentInfo(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getParentPaymentInfo() { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getPaymentSettings(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getPaymentSettings() { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getProductOrders(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getProductOrders(pageNumber!) { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
    
    func getProductOrderDetails(completed: @escaping ((ApiResponseHandler ) -> Void)) {
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            // Get data from API
            
            ParentWalletApiManager.sharedInstance.getProductOrderDetails(orderID!) { (apiResponseHandler, error) in
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed((apiResponseHandler))
            }
            
        }
    }
}
