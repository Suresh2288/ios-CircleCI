//
//  UtilitiesApiManager.swift
//  Plano
//
//  Created by Thiha Aung on 24/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SwiftyUserDefaults
import Reachability
import HTTPStatusCodes
import AlamofireObjectMapper

class UtilitiesApiManager {
    
    static let sharedInstance = UtilitiesApiManager()
    
    //MARK: - FAQs
    func getFAQs(_ data:GetFAQRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetFAQs(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }

    //MARK: - Policy
    func getPolicy(_ data:GetPolicyRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.GetPolicy(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    //MARK: - Policy
    func updateFeedback(_ data:UpdateFeedbackRequest, completed: @escaping completionHandler) {
        
        APIManager.sharedInstance.sendJSONRequest(method: .post, path: APIManager.Router.UpdateFeedback(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
}
