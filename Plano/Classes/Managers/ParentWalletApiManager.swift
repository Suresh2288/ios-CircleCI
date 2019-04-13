//
//  ParentWalletApiManager.swift
//  Plano
//
//  Created by Thiha Aung on 5/28/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SwiftyUserDefaults
import HTTPStatusCodes
import AlamofireObjectMapper

class ParentWalletApiManager {
    
    static let sharedInstance = ParentWalletApiManager()
    
    func getAllProductForParent(_ data:ParentProductsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAllProductForParent(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getProductDetailForParent(_ data:ParentProductDetailRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetParentProductDetail(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updatePurchaseProduct(_ data:UpdatePurchaseProductRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdatePurchaseProduct(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getShopBanner(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ParentProductsRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetShopBanner(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getFeaturedProducts(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ParentProductsRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetFeaturedProducts(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getParentPaymentInfo(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ParentProductsRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetParentPaymentInfo(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                print("data.toJSON():\(requestParam)")
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getPaymentSettings(completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = ParentProductsRequest(email: profile.email, accessToken: profile.accessToken).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPaymentSettings(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                print("data.toJSON():\(requestParam)")
                print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getProductOrders(_ PageNo:String, completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetProductOrderRequest(email: profile.email, accessToken: profile.accessToken, pageNo:PageNo).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetProductOrders(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
    
    func getProductOrderDetails(_ OrderID:String, completed: @escaping completionHandler) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let requestParam = GetProductOrderDetailRequest(email: profile.email, accessToken: profile.accessToken, orderUUID:OrderID).toJSON()
            
            APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetProductOrderDetails(), parameters: requestParam) { (apiResponseHandler, error) -> Void in
                
                completed(apiResponseHandler, error)
            }
        }
    }
}
