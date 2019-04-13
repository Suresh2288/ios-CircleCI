//
//  LinkWithFacebookViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import ObjectMapper
import RealmSwift

class LinkWithFacebookViewModel {
    
    var registerDataModel:RegisterData?
    
    var password: String?
    var email: String = ""
    var fbToken:String = ""
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func submitForm(completed:@escaping ((_ success:Bool, _ errorMessage:String?) -> Void)) {

        guard let password = password, !email.isEmpty, !fbToken.isEmpty else {
            log.error("form is not valid")
            return
        }

        guard !password.isEmpty else {
            log.error("form is not valid")
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            let request = LinkwithFacebookRequest(email: email, password: password, fbToken: fbToken)
            APIManager.sharedInstance.linkWithFacebook(request) {(response, error) in
                
                if response.isSuccess() {
                    // 1) call get Profile api
                    // 2) save Access_Token
                    // 3) save Profile Obj in Realm
                    // 4) show Dashboard
                    
                    if let response = Mapper<LoginDataResponse>().map(JSONObject: response.jsonObject) {
                        
                        if let profile = response.profile {
                            
                            // 3) save Profile Obj in Realm
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(ProfileData.self)) // clear old one
                                realm.add(profile) // add new one
                            }
                            
                            // 4) show Dashboard
                            completed(true, nil)
                            return
                        }
                    }
                    
                    completed(false, "Something went wrong. Please try again!".localized())
                    
                }else{
                    completed(false, response.errorMessage())
                }
                
            }
        }
        
    }

}

