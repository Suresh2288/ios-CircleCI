//
//  CreateProfileViewModel.swift
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

typealias getCounriesListHandler = (_ response: Results<CountryData>?, _ selectedCountry:CountryData?) -> Void
typealias getCitiesListHandler = (_ response: Results<CityData>?, _ selectedCity:CityData?) -> Void

class CreateProfileViewModel {
    
    var countries: Results<CountryData> = CountryData.getAllObjects()
    var cities: Results<CityData> = CityData.getAllObjects()
    var registerDataModel:RegisterData?
    
    var activeProfile:ProfileData? = ProfileData.getProfileObj()
    
    var selectedCountry: CountryData? {
        didSet {
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CityData.self)) // remove cached cities
            }
            
            selectedCity = nil // remove selected city
            countryDataUpdatedCallback!(selectedCountry)
            //            evaluateValidity()
        }
    }
    
    var selectedCity: CityData?  {
        didSet {
            cityDataUpdatedCallback!(selectedCity)
            //            evaluateValidity()
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
    var countryCode: String? {
        didSet {
            //            evaluateValidity()
        }
    }
    var mobileNumber: String? {
        didSet {
            //            evaluateValidity()
        }
    }
    
    var appFlyerId: String? {
        didSet {
            //            evaluateValidity()
        }
    }
    
    var ipAddress: String? {
        didSet {
            //            evaluateValidity()
        }
    }
    
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
    var afterCountryCitySelected : (() -> Void)?
    
    func assignRegisterDataModel(_ rdm:RegisterData) {
        registerDataModel = rdm
        firstName = rdm.firstName
        lastName = rdm.lastName
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
        
        guard cities.count < 1 else { // pass cached value if have
            completed(cities, selectedCity)
            return
        }
        
        if let country = selectedCountry {
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                let cityData = CityDataRequest(sortname: country.id)
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
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.passwordRequired.message())
            
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
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.firstNameRequired.message())
            
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
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.lastNameRequired.message())
            
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
        /*
         if let value = mobileNumber {
         
         let digitPattern = ContainsNumberValidationPattern()
         let rule = ValidationRulePattern(pattern: digitPattern, error: ValidationErrors.digits.message())
         
         let result = Validator.validate(input: value, rule: rule)
         
         switch result {
         case .valid:
         isMobileNumberValidCallback?(ValidationObj(isValid: true, error: nil))
         isValid = isValid == true
         case .invalid(let failureErrors):
         isMobileNumberValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
         isValid = false
         }
         }else{
         isValid = false
         }
         
         if let value = countryCode {
         
         let digitPattern = ContainsNumberValidationPattern()
         let rule = ValidationRulePattern(pattern: digitPattern, error: ValidationErrors.digits.message())
         
         let result = Validator.validate(input: value, rule: rule)
         
         switch result {
         case .valid:
         isCountryCodeValidCallback?(ValidationObj(isValid: true, error: nil))
         isValid = isValid == true
         case .invalid(let failureErrors):
         isCountryCodeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
         isValid = false
         }
         }else{
         isValid = false
         }
         */
        if let _ = selectedCountry {
            isValid = isValid == true
        }else{
            isValid = false
        }
        
        if let _ = selectedCity {
            isValid = isValid == true
        }else{
            isValid = false
        }
        
        isFormValid?(isValid)
        
    }
    
    // Form Submission
    
    func shouldRegisterWithFacebook() -> Bool {
        if let reg = registerDataModel {
            if let fbid = reg.fbid {
                return !fbid.isEmpty
            }
        }
        
        return false
    }
    
    func submitForm(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        if let reg = registerDataModel {
            
            reg.firstName = firstName!
            reg.lastName = lastName!
            if let country = selectedCountry{
                reg.country = country.id
            }
            if let city = selectedCity{
                reg.city = city.id
            }
            //            reg.countryCode = countryCode!
            //            reg.mobile = mobileNumber!
            
            reg.appFlyerId = Defaults[.appFlyerId]!
            reg.ipAddress = Defaults[.ipAddress]!
            
            if let pib64 = profileImageInBase64 {
                reg.profileImage = pib64
            }
            
            print("data.toJSON():\(reg)")
            
        
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                APIManager.sharedInstance.registerWithEmail(reg) {[weak self](apiResponseHandler, error) in
                    
                    self?.afterApiCall?() // after hook. hiding HUD
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let list = Mapper<RegisterDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let profile = list.profile {
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(ProfileData.self)) // clear old one
                                    realm.add(profile) // add new one
                                    
                                    if let parentProfile = ProfileData.getProfileObj() {
                                        WoopraTrackingPage().profileInfo(name: "\(parentProfile.firstName) \(parentProfile.lastName)", email: parentProfile.email,country: (Locale.current as NSLocale).object(forKey: .countryCode) as! String, city: (parentProfile.city  ?? ""),countryCode: (parentProfile.countryCode ?? ""), mobile: parentProfile.mobile, profileImage: (parentProfile.profileImage ?? ""),deviceType: "iOS",deviceID: parentProfile.accessToken)
                                        WoopraTrackingPage().trackEvent(mainMode:"Parent Register Page",pageName:"Register Page",actionTitle:"User Registration success")
                                    }

                                }
                            }
                        }
                        
                        /* 12 Oct 2017
                         * -----------
                         * Email verification is dropped. So no longer need to do verification
                         * and brings user to dashboard directly
                         */
                        // If form is success, store the email/pw temporarily so that after email validation is done, auto login for user
                        //                        Defaults[.tempEmailOfNewUser] = reg.email
                        //                        Defaults[.tempPWOfNewUser] = reg.password
                        
                        success(ValidValidationObj())
                        
                    }else{
                        
                        failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())))
                    }
                }
            }
            
        }
        
        submitFormCallback?()
    }
    
    
    func registerWithFacebook(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        if let reg = registerDataModel {
            
            reg.firstName = firstName!
            reg.lastName = lastName!
            if let country = selectedCountry{
                reg.country = country.id
            }
            if let city = selectedCity{
                reg.city = city.id
            }
            if let data = countryCode{
                reg.countryCode = data
            }
            if let data = mobileNumber{
                reg.mobile = data
            }
            if let fbid = reg.fbid {
                reg.profileImage = makeFacebookProfileImageUrl(fbid: fbid)
            }
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                APIManager.sharedInstance.registerWithFacebook(reg) {[weak self](apiResponseHandler, error) in
                    
                    self?.afterApiCall?() // after hook. hiding HUD
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let list = Mapper<FacebookRegisterDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let pf = list.profile {
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(ProfileData.self)) // clear old one
                                    realm.add(pf) // add new one
                                }
                                WoopraTrackingPage().trackEvent(mainMode:"Parent Register Page",pageName:"Register Page",actionTitle:"User login through facebook")
                                
                                success(ValidValidationObj())
                                return
                            }
                        }
                    }
                    
                    failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())))
                    
                }
            }
        }
        
        submitFormCallback?()
    }
    
    func saveNewProfileInRealm(regData:RegisterData, accessToken:String){
        
        let realm = try! Realm()
        let profile = ProfileData()
        
        // stupid manual mapping
        profile.email = regData.email
        profile.firstName = regData.firstName
        profile.lastName = regData.lastName
        profile.countryResidence = regData.country
        profile.city = regData.city
        profile.countryCode = regData.countryCode
        profile.mobile = regData.mobile
        profile.profileImage = regData.profileImage
        profile.accessToken = accessToken // save AccessToken because user want to skip Email Verification
        
        try! realm.write {
            realm.delete(realm.objects(ProfileData.self)) // clear old one
            realm.add(profile) // add new one
        }
        
    }
    
    
    func makeFacebookProfileImageUrl(fbid:String) -> String {
        return "https://graph.facebook.com/\(fbid)/picture?type=large"
    }
    
    
    
    // MARK: Make Singapore Default Country/City
    func callCountriesCityListWithDefaultValue(){
        let countryCode = NSLocale.current.regionCode as String?
        print(countryCode!)
        self.getCountriesList {[weak self](list, selected) in
            let pred = NSPredicate(format: "id=%@", countryCode!)
            if let country:CountryData = list!.filter(pred).first {
                self?.selectedCountry = country
                
                self?.getCitiesList {(list, selected) in                    
                    if list != nil {
                        if let city:CityData = list!.first {
                            self?.selectedCity = city
                        }
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



//- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
//    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    return [UIImage imageWithData:data];
//}

