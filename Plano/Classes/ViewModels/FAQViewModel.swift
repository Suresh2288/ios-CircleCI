//
//  FAQViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/24/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class FAQViewModel{
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func getFAQs(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
            
        let data = GetFAQRequest()
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
        beforeApiCall?()
        
            UtilitiesApiManager.sharedInstance.getFAQs(data, completed: {[weak self] (apiResponseHandler,error) in
                
                self?.afterApiCall?()
                
                if apiResponseHandler.isSuccess() {
                    
                    if let response = Mapper<GetFAQResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let faqs = response.faqs{
                            let realm = try! Realm()
                            
                            try! realm.write {
                                realm.delete(realm.objects(FAQs.self))
                                realm.add(faqs)
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

