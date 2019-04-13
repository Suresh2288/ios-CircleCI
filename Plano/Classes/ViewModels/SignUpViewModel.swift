//
//  SignUpViewModel.swift
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

enum PWStrength:Int {
    case weakest = 4
    case weaker = 3
    case weak = 2
    case strong = 1
    case stronger = 0
}

class SignUpViewModel {
    
    let validationMinChar = 8
    let validationMaxChar = 99
    var newAccount:Bool = false
    var registerDataModel:RegisterData?
    
    var email: String? {
        didSet {
            checkAccountBeforeRegister()
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
    var isPasswordValidCallback : (([ValidationObj]) -> Void)?
    var isConfirmPasswordValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var passwordStrengthCallback : ((_ strength:PWStrength) -> Void)?
    var submitFormCallback : ((_ registerDataModel: RegisterData) -> Void)?
    
    var isNewEmailChecking : ((_ validationObj: ValidationObj) -> Void)?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    private func evaluateValidity(){
        
        if newAccount == true{
            isValid = true
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
                isValid = isValid == true // only valid if Email is Valid
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
        
//        evaluateValidity()
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        let registerDataModel = RegisterData(email: email!, password: password!, firstName: "", lastName: "", country: "", city: "", countryCode: "", mobile: "", accountTypeID: "", profileImage: "")
        
        submitFormCallback?(registerDataModel)
        
    }
    
    func checkAccountBeforeRegister(){
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

                self.isValid = true
                
                if ReachabilityUtil.shareInstance.isOnline(){
                
                    beforeApiCall?()
                
                    let request = CheckAccountBeforeRegisterRequest(email: em, appsflyerID: Defaults[.appFlyerId]!, ipAddress: Defaults[.ipAddress]!)
                    
                    APIManager.sharedInstance.checkAccountBeforeRegister(data: request) {[weak self] apiResponseHandler, error in
                        
                        self?.afterApiCall?() // after hook. hiding HUD
                        
                        if let response = Mapper<CheckAccountBeforeRegisterResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            let type = response.getAccountType()
                            if type == .type0{
                                self?.newAccount = true
                                self?.isEmailValidCallback?(ValidationObj(isValid: true, error: nil))
                                self?.isNewEmailChecking?(ValidationObj(isValid: true, error: nil))
                            }else{
                                self?.newAccount = false
                                self?.isValid = false
                                self?.isNewEmailChecking?(ValidationObj(isValid: false, error: nil))
                            }
                        }
                    }
                    
                }
            case .invalid(let failureErrors):
                let error:ValidationError = failureErrors.first! as! ValidationError
                isEmailValidCallback?(ValidationObj(isValid: false, error: error))
                isValid = false
            }
        }else{
            isValid = false
        }
    }
}
