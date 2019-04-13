//
//  FeedbackViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/25/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class FeedbackViewModel{
    
    var categoryName : String?
    var descriptionText : String?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func updateFeedback(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            let data = UpdateFeedbackRequest()
            data.email = profile.email
            data.name = profile.firstName + " " + profile.lastName
            data.categoryName = categoryName
            data.descriptionText = descriptionText
            
            if ReachabilityUtil.shareInstance.isOnline(){
            
                beforeApiCall?()
                
                UtilitiesApiManager.sharedInstance.updateFeedback(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success()
                        
                    }else{
                        failure(apiResponseHandler.errorMessage())
                    }
                })
            }
        }
    }
}
