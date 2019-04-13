//
//  AddChildViewModel.swift
//  Plano
//
//  Created by Paing Pyi on 1/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import SwiftDate

enum InfoBased:String {
    case prescription = "Prescription"
    case memory = "Memory"
}

class AddChildViewModel {
    
    var childProfile:ChildProfile? {
        didSet {
            updatedChildProfile()
        }
    }
    
    var addChildData:AddChildData?

    var profileImage: UIImage? {
        didSet {
            if let pi = profileImage {
                profileImageInBase64 = pi.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
            }
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
    var dob: Date? {
        didSet {
            evaluateValidity()
        }
    }
    var gender: Bool? {
        didSet {
            evaluateValidity()
        }
    }
    var eyeVisionTested: Bool? {
        didSet {
            evaluateValidity()
        }
    }
    
    var leftEyeDegreeBefore: String? {
        didSet {
            evaluateValidity()
        }
    }
    var rightEyeDegreeBefore: String? {
        didSet {
            evaluateValidity()
        }
    }
    var leftEyeDegree: String? {
        didSet {
            evaluateValidity()
        }
    }
    var rightEyeDegree: String? {
        didSet {
            evaluateValidity()
        }
    }

    var selectedLeftEyeBefore:ListEyeDegrees? {
        didSet {
            leftEyeBeforeUpdatedCallback?()
            leftEyeDegreeBefore = selectedLeftEyeBefore?.EyeDegreeDescription
        }
    }
    var selectedRightEyeBefore:ListEyeDegrees? {
        didSet {
            rightEyeBeforeUpdatedCallback?()
            rightEyeDegreeBefore = selectedRightEyeBefore?.EyeDegreeDescription
        }
    }
    var selectedLeftEye:ListEyeDegrees?{
        didSet {
            leftEyeUpdatedCallback?()
            leftEyeDegree = selectedLeftEye?.EyeDegreeDescription
        }
    }
    var selectedRightEye:ListEyeDegrees?{
        didSet {
            rightEyeUpdatedCallback?()
            rightEyeDegree = selectedRightEye?.EyeDegreeDescription
        }
    }

    var wearGlasses: Bool? {
        didSet {
            evaluateValidity()
        }
    }
    
    var wearGlassesYear: String? {
        didSet {
            evaluateValidity()
        }
    }
    var wearGlassesMonth: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var eyeCheckYear: String? {
        didSet {
            evaluateValidity()
        }
    }
    var eyeCheckMonth: String? {
        didSet {
            evaluateValidity()
        }
    }
    
    var infoBased: InfoBased? {
        didSet {
            evaluateValidity()
        }
    }

    var isValid:Bool = false { // To decide if should allow to go next or not
        didSet {
            isFormValid?(oldValue)
        }
    }
    
    var profileImageInUrl:String?
    var profileImageInBase64:String?

    var childProfileUpdatedCallback : (() -> ())?
    var isFirstNameValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isLastNameValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isDOBValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isEyeTestedValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isGenderValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    
    var isLeftEyeBeforeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var isRightEyeBeforeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var isLeftEyeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var isRightEyeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    var isFormValid: ((_ valid:Bool) -> Void)?
    var submitFormCallback : (() -> ())?

    var wearGlassesYearValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var wearGlassesMonthValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var eyeCheckYearValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var eyeCheckMonthValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var leftEyeBeforeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var rightEyeBeforeMonthValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var leftEyeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    var rightEyeValidCallback: ((_ validationObj: ValidationObj) -> Void)?
    
    var leftEyeBeforeUpdatedCallback: (() -> ())?
    var rightEyeBeforeUpdatedCallback: (() -> ())?
    var leftEyeUpdatedCallback: (() -> ())?
    var rightEyeUpdatedCallback: (() -> ())?

    var isInEditMode:Bool = false
    ///// Validation
    
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
        
        if dob != nil {
            isDOBValidCallback?(ValidationObj(isValid: true, error: nil))
            isValid = isValid == true
        }else{
            isValid = false
        }
        
        if gender != nil {
            isGenderValidCallback?(ValidationObj(isValid: true, error: nil))
            isValid = isValid == true

        }else{
            isValid = false
        }
        
        /*
        if eyeVisionTested != nil {
            isEyeTestedValidCallback?(ValidationObj(isValid: true, error: nil))
            isValid = isValid == true
            
        }else{
            isValid = false
        }
        */
        
        if !isInEditMode {
            if let ev = eyeVisionTested, ev == true {
                if let value = eyeCheckMonth {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        eyeCheckMonthValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        eyeCheckMonthValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = eyeCheckYear {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        eyeCheckYearValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        eyeCheckYearValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
            }
            
            if let wg = wearGlasses, wg == true { // if "Wearning No Glass, No need to check below"
                
                isValid = infoBased != nil
                
                if let value = wearGlassesYear {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        wearGlassesYearValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        wearGlassesYearValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = wearGlassesMonth {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        wearGlassesMonthValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        wearGlassesMonthValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = leftEyeDegreeBefore {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        leftEyeBeforeValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        leftEyeBeforeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = rightEyeDegreeBefore {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        isRightEyeBeforeValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        isRightEyeBeforeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = leftEyeDegree {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        leftEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        leftEyeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = rightEyeDegree {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        rightEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                        isValid = isValid == true
                    case .invalid(let failureErrors):
                        rightEyeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                ///////
                
                if let value = leftEyeDegreeBefore {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        isValid = isValid == true
                        isLeftEyeBeforeValidCallback?(ValidationObj(isValid: true, error: nil))
                    case .invalid(_):
                        isLeftEyeBeforeValidCallback?(ValidationObj(isValid: false, error: nil))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                if let value = rightEyeDegreeBefore {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        isValid = isValid == true
                        isRightEyeBeforeValidCallback?(ValidationObj(isValid: true, error: nil))
                    case .invalid(_):
                        isRightEyeBeforeValidCallback?(ValidationObj(isValid: false, error: nil))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                // no need to check `isValid` because leftEye and rightEye are just for visual
                if let value = leftEyeDegree {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        isValid = isValid == true
                        isLeftEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                    case .invalid(_):
                        isLeftEyeValidCallback?(ValidationObj(isValid: false, error: nil))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
                
                if let value = rightEyeDegree {
                    
                    let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
                    
                    let result = Validator.validate(input: value, rule: rule)
                    
                    switch result {
                    case .valid:
                        isValid = isValid == true
                        isRightEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                    case .invalid(_):
                        isRightEyeValidCallback?(ValidationObj(isValid: false, error: nil))
                        isValid = false
                    }
                }else{
                    isValid = false
                }
                
            }
        }
        
    }
    
    
    func submitForm(success: @escaping (_ childID: String) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        var dobString = ""
        
        if let dobDate = dob {
            dobString = dobDate.toStringWith(format: "yyyy-MM-dd")
        }
        
        if let profile = ProfileData.getProfileObj() {
        
            let model = prepareChildData(profile: profile)
            model.parentEmail = profile.email
            model.dob = dobString
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                ChildApiManager.sharedInstance.addChildProfile(model, completed: {[weak self](apiResponseHandler, error) in
                    self?.afterApiCall?() // after hook. hiding HUD
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<AddChildResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            success(response.childID)
                        }
                        
                    }else{
                        
                        failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())))
                    }
                })
                
                submitFormCallback?()
            }

        }
        
    }
    
    func updateChildProfile(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj) -> Void) {
        
        guard isValid else {
            log.error("form is not valid")
            return
        }
        
        var dobString = ""
        
        if let dobDate = dob {
            dobString = dobDate.toStringWith(format: "yyyy-MM-dd")
        }
        
        if let profile = ProfileData.getProfileObj(), let child = childProfile {
            
            let model = prepareChildData(profile: profile)
            model.dob = dobString
            model.childID = child.childID
            model.parentEmail = profile.email
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                ChildApiManager.sharedInstance.updateChildProfile(model, completed: {[weak self](apiResponseHandler, error) in
                    self?.afterApiCall?() // after hook. hiding HUD
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success(ValidValidationObj())
                        
                    }else{
                        
                        failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())))
                    }
                })
                
                submitFormCallback?()
                
            }
        }
        
    }
    
    private func prepareChildData(profile:ProfileData) -> AddChildData {
        
        let model = AddChildData()
        
        model.accessToken = profile.accessToken
        model.firstName = firstName!
        model.lastName = lastName!
        
        if let value = eyeVisionTested {
            model.eyeTest = value
        }
        if let value = gender {
            model.gender = value
        }
        if let value = wearGlasses {
            model.wearingGlasses = value
        }
        if let value = wearGlassesYear {
            model.glassStartYear = value
        }
        if let value = wearGlassesMonth {
            model.glassStartMonth = value
        }
        if let value = eyeCheckYear {
            model.eyeCheckYear = value
        }
        if let value = eyeCheckMonth {
            model.eyeCheckMonth = value
        }
        if let value = selectedLeftEyeBefore {
            model.leftEyeBefore = value.EyeDegreeID
        }else{
            model.leftEyeBefore = "" // send empty value to server if not selected
        }
        if let value = selectedRightEyeBefore {
            model.rightEyeBefore = value.EyeDegreeID
        }else{
            model.rightEyeBefore = "" // send empty value to server if not selected
        }
        if let value = selectedLeftEye {
            model.leftEye = value.EyeDegreeID
        }else{
            model.leftEye = "" // send empty value to server if not selected
        }
        if let value = selectedRightEye {
            model.rightEye = value.EyeDegreeID
        }else{
            model.rightEye = "" // send empty value to server if not selected
        }
        if let value = infoBased {
            model.infoBased = value.rawValue
        }

        // copy the base64 image
        if let value = profileImage {
            if let base64 = value.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn) {
                model.profileImage = base64
            }
        }else{
            // no base64 and have original image url (meaning, we don't change the picture)
            if let value = profileImageInUrl {
                model.profileImage = value
            }
        }



        return model
    }
    
    func updatedChildProfile() {
        
        if let childProfile = childProfile {
            
            firstName = childProfile.firstName
            lastName = childProfile.lastName
            profileImageInUrl = childProfile.profileImage
            wearGlassesYear = childProfile.glassStartYear
            wearGlassesMonth = childProfile.glassStartMonth
            eyeCheckYear = childProfile.eyeCheckYear
            eyeCheckMonth = childProfile.eyeCheckMonth
            
            selectedLeftEyeBefore = childProfile.getEyeDegreeByID(childProfile.leftEyeBefore)
            selectedRightEyeBefore = childProfile.getEyeDegreeByID(childProfile.rightEyeBefore)
            selectedLeftEye = childProfile.getEyeDegreeByID(childProfile.leftEye)
            selectedRightEye = childProfile.getEyeDegreeByID(childProfile.rightEye)
            
            gender = childProfile.getGenderMaleBool()
            infoBased = childProfile.getInfoBasedInInt()
            wearGlasses = childProfile.getWearingGlassBool()
            eyeVisionTested = childProfile.didEyeTested()

            dob = childProfile.dob
        }
        
        childProfileUpdatedCallback?()
    }

    func getProfileImageUrl() -> String? {
        if let cp = self.childProfile {
            return cp.profileImage
        }
        return nil
    }

    func getEyeTestDescription() -> String{
        if let dob = dob {
            let past2 = Date()-2.years
            let past5 = Date()-5.years
            
            if(dob >= past2){
                return "plano recommends an eye test, preferably at 6 months old.".localized()
            }else if(dob < past2 && dob >= past5){
                return "plano recommends an eye test at least once, preferrably at 3 years old.".localized()
            }else{
                return "plano recommends an eye test annually".localized()
            }
        }
        return "plano recommends an eye test, preferably at 6 months old.".localized()
    }
}
