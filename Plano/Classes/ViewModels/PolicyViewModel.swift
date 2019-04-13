//
//  PolicyViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/25/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class PolicyViewModel{
        
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func getPolicy(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        let data = GetPolicyRequest()
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?()
            
            UtilitiesApiManager.sharedInstance.getPolicy(data, completed: {[weak self] (apiResponseHandler,error) in
                
                self?.afterApiCall?()
                
                if apiResponseHandler.isSuccess() {
                    
                    if let response = Mapper<GetPolicyResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        guard let aboutPlano = response.aboutPlano else{
                            return
                        }
                        
                        guard let termsAndConditions = response.termsAndConditions else{
                            return
                        }
                        
                        guard let pdpa = response.pdpa else{
                            return
                        }
                        
                        guard let privacypolicy = response.privacypolicy else{
                            return
                        }
                        
                        let policies = Policies()
                        policies.aboutPlano = aboutPlano
                        policies.termsAndCondition = termsAndConditions
                        policies.pdpa = pdpa
                        policies.privacypolicy = privacypolicy
                        
                        let realm = try! Realm()
                        
                        try! realm.write {
                            realm.delete(realm.objects(Policies.self))
                            realm.add(policies)
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
