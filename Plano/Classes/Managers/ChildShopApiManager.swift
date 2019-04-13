//
//  ChildShopApiManager.swift
//  Plano
//
//  Created by Thiha Aung on 5/27/17.
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

class ChildShopApiManager {
    
    static let sharedInstance = ChildShopApiManager()
    
    func getAllProductForChild(_ data:ChildProductsRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetAllProductForChild(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func getProductDetailForChild(_ data:ChildProductDetailRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetChildProductDetail(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
    func updateChildRequestProduct(_ data:UpdateChildRequestProduct, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateChildRequestProduct(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
        
    }
    
}
