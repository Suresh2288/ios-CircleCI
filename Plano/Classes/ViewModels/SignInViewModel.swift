//
//  SignInViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class SignInViewModel {
    
    let validationMinChar = 8
    let validationMaxChar = 99
    
    var firstName:String?
    var lastName:String?
    var fbid:String?
    var fbToken:String?
    
    var email: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var password: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var isValid:Bool = false // To decide if should allow to go next or not
    
    var isEmailValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isPasswordValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    var checkAccountType0Callback : ((_ registerDataModel:RegisterData) -> Void)?
    var checkAccountType1Callback : ((_ email:String, _ fbToken:String) -> Void)?
    var checkAccountType2Callback : ((_ validationObj: ValidationObj) -> Void)?
    var checkAccountType3Callback : ((_ success:Bool, _ errorMessage:String?) -> Void)?
    
    private func evaluateValidity(){
        
        if let em = email {
            
            // Validation Array Holder
            var emailRules = ValidationRuleSet<String>()
            let emailPattern = ValidationRulePattern(
                pattern: EmailValidationPattern.standard,
                error: ValidationErrors.emailInvalid.message()) // Email Validator
            emailRules.add(rule: emailPattern) // Assign
            
            // Do validation and return valid/invalid
            let result = Validator.validate(input: em, rules: emailRules)
            
            switch result {
            case .valid:
                isValid = true
                isEmailValidCallback?(ValidationObj(isValid: true, error: nil))
                
            case .invalid(let failureErrors):
                isValid = false
                let error:ValidationError = failureErrors.first! as! ValidationError
                isEmailValidCallback?(ValidationObj(isValid: false, error: error))
            }
        }else{
            isValid = false
        }
        
        
        if let pw = password {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.passwordRequired.message())
            
            let result = Validator.validate(input: pw, rule: rule)
            
            switch result {
            case .valid:
                isValid = true
                isPasswordValidCallback?(ValidationObj(isValid: true, error: nil))
                
            case .invalid(let failureErrors):
                isValid = false
                isPasswordValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
            }
        }else{
            isValid = false
        }
        
        
    }
    
    
    
    func login(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            let data = LoginData(email: email, password: password)
            APIManager.sharedInstance.login(data: data) {[weak self](apiResponseHandler, error) in
                
                self?.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    
                    
                    if let response = Mapper<LoginDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let profile = response.profile {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(ProfileData.self)) // clear old one
                                realm.add(profile) // add new one
                            }
                        }
                    }
                    
                    success(ValidationObj(isValid: true,
                                          error: nil))
                    
                    
                    if let parentProfile = ProfileData.getProfileObj() {
                        WoopraTrackingPage().profileInfo(name: "\(parentProfile.firstName) \(parentProfile.lastName)", email: parentProfile.email,country: (Locale.current as NSLocale).object(forKey: .countryCode) as! String, city: (parentProfile.city  ?? ""),countryCode: (parentProfile.countryCode ?? ""), mobile: parentProfile.mobile, profileImage: (parentProfile.profileImage ?? ""),deviceType: "iOS",deviceID: parentProfile.accessToken)
                        WoopraTrackingPage().trackEvent(mainMode:"Parent Login Page",pageName:"Login Page",actionTitle:"User logged")
                    }
                    
                }else{
                    
                    failure(ValidationObj(isValid: false,
                                          error: ValidationError(message: apiResponseHandler.errorMessage())))
                    
                }
            }
        }
    }
    
    
    
    func loginWithFacebook(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard let em = email, let token = fbToken else {
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            let request = FacebookLoginData(email: em, fbToken: token)
            
            APIManager.sharedInstance.loginWithFacebook(data: request) {[weak self] apiResponseHandler, error in
                
                self?.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    
                    if let response = Mapper<LoginDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let profile = response.profile {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(ProfileData.self)) // clear old one
                                realm.add(profile) // add new one
                            }
                        }
                    }
                    
                    success(ValidationObj(isValid: true,
                                          error: nil))
                    
                }else{
                    
                    failure(ValidationObj(isValid: false,
                                          error: ValidationError(message: apiResponseHandler.errorMessage())))
                    
                }
            }
        }
    }
    
    
    func checkAccountBeforeRegister(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard let em = email else {
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            let request = CheckAccountBeforeRegisterRequest(email: em, appsflyerID: Defaults[.appFlyerId]!, ipAddress: Defaults[.ipAddress]!)
            
            APIManager.sharedInstance.checkAccountBeforeRegister(data: request) {[weak self] apiResponseHandler, error in
                
                self?.afterApiCall?() // after hook. hiding HUD
                
                if let response = Mapper<CheckAccountBeforeRegisterResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    let type = response.getAccountType()
                    //                let type:registerAccountType = type1
                    
                    /*
                     AccountType:0
                     Description:No registered account
                     > u have any register account
                     > show `Password` page and `CreateProfile` screen later
                     
                     AccountType:1
                     Description:Normal Register
                     > u already register with normal login if u want to login with facebook use -> LinkwithFacebook
                     
                     AccountType:2
                     Description:Facebook Register
                     > u don't need any register if facebook register bez i already asked Password in this api -> CreateProfileWithFacebook
                     
                     AccountType:3
                     Description:Normal and Facebook Register
                     > no need to do anything, all are link
                     */
                    
                    let registerDataModel = RegisterData(email: em, password: "", firstName: "", lastName: "", country: "", city: "", countryCode: "", mobile: "", accountTypeID: "", profileImage: "")
                    
                    if let data = self?.firstName {
                        registerDataModel.firstName = data
                    }
                    if let data = self?.lastName {
                        registerDataModel.lastName = data
                    }
                    
                    if let data = self?.fbid {
                        registerDataModel.fbid = data
                    }
                    
                    if let data = self?.fbToken {
                        registerDataModel.accountTypeID = data
                    }
                    
                    switch type {
                        
                    case .type0:
                        
                        self?.checkAccountType0Callback?(registerDataModel)
                        
                    case .type1:
                        
                        if let email = self?.email, let fbToken = self?.fbToken {
                            self?.checkAccountType1Callback?(email,fbToken)
                        }
                        
                    default:
                        
                        self?.loginWithFacebook(success: { validationObj in
                            self?.checkAccountType2Callback?(validationObj)
                        }, failure: { validationObj in
                            self?.checkAccountType2Callback?(validationObj)
                        })
                        
                    }
                    
                    return
                }
                
                
            }
        }
    }
    
}

