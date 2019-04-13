//
//  UpdateProfileViewModel.swift
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

class UpdateProfileViewModel {
    
    var countries: Results<CountryData> = CountryData.getAllObjects()
    var cities: Results<CityData> = CityData.getAllObjects()
    
    var activeProfile:ProfileData? = ProfileData.getProfileObj()
    
    var afterCountryCitySelected : (() -> Void)?
    
    var selectedCountry: CountryData? {
        didSet {
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CityData.self)) // remove cached cities
            }
            
            selectedCity = nil // remove selected city
            countryDataUpdatedCallback!(selectedCountry)
            evaluateValidity()
        }
    }
    
    var selectedCity: CityData?  {
        didSet {
            cityDataUpdatedCallback!(selectedCity)
            evaluateValidity()
        }
    }
    
    var email: String? {
        didSet {
            evaluateValidityForEmailPassword()
        }
    }
    var password: String? {
        didSet {
            evaluateValidityForEmailPassword()
        }
    }
    
    var firstName: String? {
        didSet {
            evaluateValidity()
        }
    }
    var lastName: String? {
        didSet {
            evaluateValidity()
        }
    }
//    var countryCode: String? {
//        didSet {
//            evaluateValidity()
//        }
//    }
//    var mobileNumber: String? {
//        didSet {
//            evaluateValidity()
//        }
//    }
    var profileImage: UIImage? {
        didSet {
            if let pi = profileImage {
                profileImageInBase64 = pi.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
            }
        }
    }
    var profileImageInBase64:String?
    
    var isUpdateProfile:Bool = false
    var isValid:Bool = false // To decide if should allow to go next or not
    
    var countryDataUpdatedCallback : ((_ data:CountryData?) -> Void)?
    var cityDataUpdatedCallback : ((_ data:CityData?) -> Void)?
    
    var isEmailValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isPasswordValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isFirstNameValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isLastNameValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isCountryCodeValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isMobileNumberValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var submitFormCallback : (() -> ())?
    var isFormValid: ((_ valid:Bool) -> Void)?

    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    
    func getProfileFromApi(completed: @escaping (_ profileObj: ProfileData?) -> Void ){
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?()
            
            guard let profile = self.activeProfile else {
                return
            }
            
            let request = GetProfileRequest(email: profile.email, accessToken: profile.accessToken)
            APIManager.sharedInstance.getProfile(request) { (apiResponseHandler, error) in
                if apiResponseHandler.isSuccess() {
                    if let obj = Mapper<LoginDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        if let prf = obj.profile {
                            let realm = try! Realm()
                            let at = profile.accessToken // bug fix from server
                            try! realm.write {
                                prf.accessToken = at // bug fix from server
                                realm.add(prf, update: true) // add new one
                            }
                            completed(prf)
                            return
                        }
                    }
                }
                
                completed(nil)
            }
        }
    }
    
    func getCountriesList(completed: @escaping  getCounriesListHandler){
        
        guard countries.count < 1 else { // pass cached value if have
            completed(countries, selectedCountry)
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
        
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            APIManager.sharedInstance.getCountries() {(apiResponseHandler, error) in
                
                self.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    
                    if let list = Mapper<CountryDataList>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let data = list.countries {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(CountryData.self)) // clear old one
                                realm.add(data) // add new one
                            }
                            
                            self.countries = realm.objects(CountryData.self)
                            completed(self.countries, self.selectedCountry)
                            
                        }
                    }
                    
                }else{
                    completed(nil, nil)
                }
            }
        }
    }
    
    func getCitiesList(completed: @escaping  getCitiesListHandler){
        
        if let country = selectedCountry {
            
            getCitiesList(countryID: country.id, completed: completed)
        }
        
    }
    
    func getCitiesList(countryID:String, completed: @escaping  getCitiesListHandler){
        
        guard cities.count < 1 else { // pass cached value if have
            completed(cities, selectedCity)
            return
        }
        
        if ReachabilityUtil.shareInstance.isOnline(){
    
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            let cityData = CityDataRequest(sortname: countryID)
            APIManager.sharedInstance.getCities(cityData) {(apiResponseHandler, error) in
                
                self.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    
                    if let list = Mapper<CityDataList>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        if let data = list.cities {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(realm.objects(CityData.self)) // clear old one
                                realm.add(data) // add new one
                            }
                            
                            self.cities = realm.objects(CityData.self)
                            completed(self.cities, self.selectedCity)
                        }
                    }
                    
                }else{
                    completed(nil, nil)
                }
            }
        }
        
    }
    
    ///// Validation
    private func evaluateValidityForEmailPassword(){
        
        if let em = email {
            
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
        
        if let pw = password {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
            
            let result = Validator.validate(input: pw, rule: rule)
            
            switch result {
            case .valid:
                isPasswordValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = isValid == true
            case .invalid(let failureErrors):
                isPasswordValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                isValid = false
            }
        }else{
            isValid = false
        }
        
        
    }
    
    func evaluateValidity(){
        
        if let value = firstName {

            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
            
            let result = Validator.validate(input: value, rule: rule)
            
            switch result {
                case .valid:
                    isFirstNameValidCallback?(ValidationObj(isValid: true, error: nil))
                    isValid = true
                case .invalid(let failureErrors):
                    isFirstNameValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                    isValid = false
            }
        }else{
            isValid = false
        }
        
        if let value = lastName {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
            
            let result = Validator.validate(input: value, rule: rule)
            
            switch result {
            case .valid:
                isLastNameValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = isValid == true
            case .invalid(let failureErrors):
                isLastNameValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                isValid = false
            }
        }else{
            isValid = false
        }
        
//        if let value = mobileNumber {
//            
//            let digitPattern = ContainsNumberValidationPattern()
//            let rule = ValidationRulePattern(pattern: digitPattern, error: ValidationErrors.digits.message())
//
//            let result = Validator.validate(input: value, rule: rule)
//            
//            switch result {
//            case .valid:
//                isMobileNumberValidCallback?(ValidationObj(isValid: true, error: nil))
//                isValid = isValid == true
//            case .invalid(let failureErrors):
//                isMobileNumberValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
//                isValid = false
//            }
//        }else{
//            isValid = false
//        }
        
//        if let value = countryCode {
//            
//            let digitPattern = ContainsNumberValidationPattern()
//            let rule = ValidationRulePattern(pattern: digitPattern, error: ValidationErrors.digits.message())
//
//            let result = Validator.validate(input: value, rule: rule)
//            
//            switch result {
//            case .valid:
//                isCountryCodeValidCallback?(ValidationObj(isValid: true, error: nil))
//                isValid = isValid == true
//            case .invalid(let failureErrors):
//                isCountryCodeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
//                isValid = false
//            }
//        }else{
//            isValid = false
//        }
        
        if let _ = selectedCountry {
            isValid = isValid == true
        }else{
            isValid = false
        }
        
        isFormValid?(isValid)

    }
    
    // Form Submission
    
    func submitForm(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        guard let profile = activeProfile else {
            return
        }
        
        let request = UpdateProfileRequest()
        request.firstName = firstName!
        request.lastName = lastName!
        request.email = email!
//        request.countryCode = countryCode!
//        request.mobile = mobileNumber!
        request.accessToken = profile.accessToken
        
        if let country = selectedCountry{
            request.countryResidence = country.id
        }else{
            request.countryResidence = ""
        }
        
        if let city = selectedCity{
            request.city = city.id
        }else{
            request.city = ""
        }
        
        if let pib64 = profileImageInBase64 {
            request.profileImage = pib64
        }else{
            request.profileImage = "0"
        }
        
        print("data.toJSON():\(request)")
   
        
        if ReachabilityUtil.shareInstance.isOnline(){
            
            beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
            
            APIManager.sharedInstance.updateProfile(request, completed: { (apiResponseHandler, error) in
                
                self.afterApiCall?() // after hook. hiding HUD
                
                if apiResponseHandler.isSuccess() {
                    
                    // save and update to local profile
                    let request = GetProfileRequest(email: profile.email, accessToken: profile.accessToken)
                    APIManager.sharedInstance.getProfile(request) { (apiResponseHandler, error) in
                        if apiResponseHandler.isSuccess() {
                            if let obj = Mapper<LoginDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                                if let prf = obj.profile {
                                    let realm = try! Realm()
                                    let at = profile.accessToken // bug fix from server
                                    try! realm.write {
                                        prf.accessToken = at // bug fix from server
                                        realm.add(prf, update: true) // add new one
                                    }
                                }
                            }
                        }
                    }

                    // forward
                    success(ValidValidationObj())
                    
                }else{
                    
                    failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())))
                }
            })
            
        }

    }
    
    func callCountriesCityListWithDefaultValue(){
        let countryCode = NSLocale.current.regionCode as String?
        print(countryCode!)
        self.getCountriesList {[weak self](list, selected) in
            let pred = NSPredicate(format: "id=%@", countryCode!)
            if let country:CountryData = list!.filter(pred).first {
                self?.selectedCountry = country
                
                self?.getCitiesList {(list, selected) in
                    if let city:CityData = list!.first {
                        self?.selectedCity = city
                    }
                    
                    self?.afterCountryCitySelected?()
                }
            }
        }
    }

    func callSelectedCountriesCityListWithDefaultValue(){
        
        self.getCitiesList {(list, selected) in
            if let city:CityData = list!.first {
                self.selectedCity = city
            }
            
            self.afterCountryCitySelected?()
        }
    }

}
