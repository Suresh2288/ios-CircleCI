//
//  SignUpViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator

class PasswordViewModel {
    
    let validationMinChar = 8
    let validationMaxChar = 99
    
    var registerDataModel:RegisterData?
    
    var email: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var currentPassword: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var password: String? {
        didSet {
            evaluateValidity()
        }
    }

    var passwordConfirm: String? {
        didSet {
            evaluateValidity()
        }
    }

    var isValid:Bool = false // To decide if should allow to go next or not

    
    var isEmailValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isCurrentPasswordValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isPasswordValidCallback : (([ValidationObj]) -> Void)?
    var isConfirmPasswordValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var passwordStrengthCallback : ((_ strength:PWStrength) -> Void)?
    var submitFormCallback : ((_ registerDataModel: RegisterData) -> Void)?
    var resetFormCallback : ((_ validationObj: ValidationObj) -> Void)?

    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    private func evaluateValidity(){
       
        if let pw = currentPassword {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.passwordRequired.message())
            
            let result = Validator.validate(input: pw, rule: rule)
            
            switch result {
            case .valid:
                isCurrentPasswordValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = isValid == true
            case .invalid(let failureErrors):
                isCurrentPasswordValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                isValid = false
            }
            
        }else{
            isValid = false
        }
        
        if let pw = password {
            
            guard !pw.isEmpty else {
                isValid = false
                isPasswordValidCallback?([ValidationObj(isValid: false, error: ValidationErrors.passwordRequired.message())])
                return
            }
            
            var passwordRules = ValidationRuleSet<String>()
    
            // min 8 characters
            let rangeLengthRule = ValidationRuleLength(min: validationMinChar, max: validationMaxChar, error: ValidationErrors.passwordRequirement.message())
            
            // min 1 digit
            let digitPattern = ContainsNumberValidationPattern()
            let digitRule = ValidationRulePattern(pattern: digitPattern, error: ValidationErrors.passwordRequirement.message())
            
            passwordRules.add(rule: digitRule)
            passwordRules.add(rule: rangeLengthRule)
            
            let result = Validator.validate(input: pw, rules: passwordRules)
            
            switch result {
            case .valid:
                isPasswordValidCallback?([ValidationObj(isValid: true, error: nil)])
                isValid = true // only valid if Email is Valid
                passwordStrengthCallback?(.stronger)
                
            case .invalid(let failureErrors):
                let realCount = failureErrors.count
                let errorCount:PWStrength = realCount == 0 ? .stronger : .weak
                passwordStrengthCallback?(errorCount)
                
                var errors:Array<ValidationObj> = []
                for fe in failureErrors {
                    errors.append(ValidationObj(isValid: false, error: fe as? ValidationError))
                }
                isPasswordValidCallback?(errors)
                isValid = false
                
            }

        }else{
            isValid = false
        }
        
        if let cp = passwordConfirm {
            
            
            guard !cp.isEmpty, let _ = self.password else {
                isValid = false
                return
            }
            
            var passwordRules = ValidationRuleSet<String>()
            let equalityRule = ValidationRuleEquality<String>(dynamicTarget: { return self.password! }, error: ValidationErrors.passwordMatch.message())
            passwordRules.add(rule: equalityRule)

            let result = Validator.validate(input: cp, rules: passwordRules) // Do validation and return valid/invalid
            
            switch result {
            case .valid:
                isConfirmPasswordValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = isValid == true // only valid if Email is Valid
            case .invalid(let failureErrors):
                let error:ValidationError = failureErrors.first! as! ValidationError
                isConfirmPasswordValidCallback?(ValidationObj(isValid: false, error: error))
                isValid = false
            }
        }else{
            isValid = false
        }
        
        
    }
    
    func submitForm() {

        guard isValid else {
            log.error("form is not valid")
            return
        }

       if let rgdm = registerDataModel, let pw = password {
            rgdm.password = pw
            submitFormCallback?(rgdm)
       }
       
    }
    
    func submitResetPasswordForm(){
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        guard let profile = ProfileData.getProfileObj(), let pw = password, let cpw = currentPassword else {
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?()
        
            let request = ResetPasswordRequest(email: profile.email, currentPassword:cpw, password: pw, accessToken: profile.accessToken)
            
            APIManager.sharedInstance.resetPassword(request) { (apiResponseHandler, error) in
                self.afterApiCall?()
                if apiResponseHandler.isSuccess() {
                    WoopraTrackingPage().trackEvent(mainMode:"Parent Reset Password Page",pageName:"Reset Password Page",actionTitle:"Password has been resetted successfully")
                    self.resetFormCallback?(ValidationObj(isValid: true, error: nil))
                }else{
                    self.resetFormCallback?(ValidationObj(isValid: false,
                                                          error: ValidationError(message: apiResponseHandler.errorMessage())))
                }
            }
            
        }
    }

}

