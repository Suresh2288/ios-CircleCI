//
//  ForgetPasswordViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator

class ForgetPasswordViewModel {
    
    var email: String? {
        didSet {
            evaluateValidity()
        }
    }

    var isValid:Bool = false // To decide if should allow to go next or not
    
    var isEmailValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    private func evaluateValidity(){
        
        if let em = email {
            
            guard !em.isEmpty else {
                isEmailValidCallback?(ValidationObj(isValid: false, error: ValidationErrors.emailRequired.message()))
                return
            }
 
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
        }
        
    }
    
    func forgetPasswordApi(success: @escaping (_ message: String?) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        guard isValid else {
                isEmailValidCallback?(ValidationObj(isValid: false, error: ValidationErrors.emailInvalid.message()))
            log.error("form is not valid")
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            let data = ForgetPW(email: email!)
            APIManager.sharedInstance.forgetPassword(data: data) {[weak self](apiResponseHandler, error) in
                
                self?.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    success(apiResponseHandler.message)
                    
                }else{
                    failure(ValidationObj(isValid: false,
                                          error: ValidationError(message: apiResponseHandler.errorMessage())))
                }
            }
        }
    }
}

