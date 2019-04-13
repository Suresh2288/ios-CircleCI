//
//  LinkedAccountsViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 6/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import Validator

class LinkedAccountsViewModel{
    
    var addedEmail : String?{
        didSet {
            evaluateValidity()
        }
    }
    var guardianEmail : String?
    var statusCode : String?
    var accept : Int?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var isValid:Bool = false // To decide if should allow to go next or not
    
    var isEmailValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    
    private func evaluateValidity(){
        
        if let em = addedEmail {
            
            var emailRules = ValidationRuleSet<String>() // Validation Array Holder
            
            let emailPattern = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid.message()) // Email Validator
            
            emailRules.add(rule: emailPattern) // Assign
            
            let result = Validator.validate(input: em, rules: emailRules) // Do validation and return valid/invalid
            
            switch result {
            case .valid:
                isEmailValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = true
            case .invalid(let failureErrors):
                let error:ValidationError = failureErrors.first! as! ValidationError
                isEmailValidCallback?(ValidationObj(isValid: false, error: error))
                isValid = false
            }
        }else{
            isValid = false
        }
    }
    
    func getLinkedAccounts(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = GetLinkedAccountsRequest()
            data.parent_email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getLinkedAccounts(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetLinkedAccountsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let linkedAccounts = response.linkedAccounts{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(LinkedAccounts.self))
                                    realm.add(linkedAccounts)
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
    
    func updateLinkedAccount(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateLinkedAccount()
            data.parent_email = profile.email
            data.guardian_email = guardianEmail!
            data.accessToken = profile.accessToken
            data.statusCode = statusCode!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateLinkedAccount(data, completed: {[weak self] (apiResponseHandler,error) in
                    
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
    
    func getPendingLinkedAccounts(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = GetPendingAccountsRequest()
            data.parent_email = profile.email
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.getPendingLinkedAccounts(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<GetPendingAccountsResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let pendingRequests = response.pendingRequests{
                                
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.delete(realm.objects(PendingRequests.self))
                                    realm.add(pendingRequests)
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
    
    func rejectPendingLinkedAccount(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = RejectPendingAccountRequest()
            data.parent_email = profile.email
            data.guardian_email = guardianEmail!
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.rejectPendingAccount(data, completed: {[weak self] (apiResponseHandler,error) in
                    
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
    
    func createLinkAccount(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void){
        
        guard isValid else {
            log.error("email is not valid")
            return
        }
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = CreateLinkAccountRequest()
            data.parent_email = profile.email
            data.guardian_email = addedEmail!
            data.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.createLinkAccount(data, completed: {[weak self] (apiResponseHandler,error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success(ValidationObj(isValid: true,
                                              error: nil))
                        
                    }else{
                        
                        failure(ValidationObj(isValid: false,
                                              error: ValidationError(message: apiResponseHandler.errorMessage())))
                        
                    }
                })
            }
        }
    }
    
    func updateRequestLink(success: @escaping () -> Void, failure: @escaping (_ errorMessage: String) -> Void){
        
        if let profile = ProfileData.getProfileObj() {
            
            let data = UpdateRequestLink()
            data.parent_email = profile.email
            data.guardian_email = guardianEmail!
            data.accessToken = profile.accessToken
            data.accept = accept!
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?()
                
                ParentApiManager.sharedInstance.updateRequestLink(data, completed: {[weak self] (apiResponseHandler,error) in
                    
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

