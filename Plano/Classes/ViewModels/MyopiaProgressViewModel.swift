//
//  MyopiaProgressViewModel.swift
//  Plano
//
//  Created by Thiha Aung on 5/1/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Validator
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults

class MyopiaProgressViewModel {
    
    var pickedDate: Date? {
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
    
    var selectedLeftEye:ListEyeDegrees?{
        didSet {
            leftEyeUpdatedCallback?()
            leftEyeDegree = selectedLeftEye?.EyeDegreeValue
        }
    }
    var selectedRightEye:ListEyeDegrees?{
        didSet {
            rightEyeUpdatedCallback?()
            rightEyeDegree = selectedRightEye?.EyeDegreeValue
        }
    }
    
    var childID : Int?
    var fromYear : Int?
    var toYear : Int?
    
    var isValid:Bool = false // To decide if should allow to go next or not
    
    var isLeftEyeValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isRightEyeValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    var isPickedDateValidCallback : ((_ validationObj: ValidationObj) -> Void)?
    
    var beforeApiCall : (() -> Void)?
    var afterApiCall : (() -> Void)?
    var isMyopiaProgressValid: ((_ valid:Bool) -> Void)?
    
    var leftEyeUpdatedCallback: (() -> ())?
    var rightEyeUpdatedCallback: (() -> ())?
    
    ///// Validation
    
    private func evaluateValidity(){
        
        if pickedDate != nil {
            if pickedDate != nil {
                isPickedDateValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = true
            } else {
                isPickedDateValidCallback?(ValidationObj(isValid: false, error: nil))
                isValid = false
            }
        }else{
            isPickedDateValidCallback?(ValidationObj(isValid: false, error: nil))
            isValid = false
        }
        
        // no need to check `isValid` because leftEye and rightEye are just for visual
        if let value = leftEyeDegree {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
            
            let result = Validator.validate(input: value, rule: rule)
            
            switch result {
            case .valid:
                isLeftEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = true
            case .invalid(let failureErrors):
                isLeftEyeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                isValid = false
            }
        }else{
            isLeftEyeValidCallback?(ValidationObj(isValid: false, error: nil))
            isValid = false
        }
        
        
        if let value = rightEyeDegree {
            
            let rule = MyValidationRuleRequired<String?>(error: ValidationErrors.required.message())
            
            let result = Validator.validate(input: value, rule: rule)
            
            switch result {
            case .valid:
                isRightEyeValidCallback?(ValidationObj(isValid: true, error: nil))
                isValid = true
            case .invalid(let failureErrors):
                isRightEyeValidCallback?(ValidationObj(isValid: false, error: failureErrors.first as? ValidationError))
                isValid = false
            }
        }else{
            isRightEyeValidCallback?(ValidationObj(isValid: false, error: nil))
            isValid = false
        }
        
        isMyopiaProgressValid?(isValid)
        
    }
    
    func getMyopiaProgressRecord(completed: @escaping ((_ hasMyopiaProgressRecords:Bool ) -> Void), failure: @escaping (_ errorMessage : String, _ errorCode: UInt) -> Void) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let model = MyopiaProgressRequest()
            model.email = profile.email
            model.childID = childID
            model.fromYear = fromYear
            model.toYear = toYear
            model.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                ParentApiManager.sharedInstance.getMyopiaProgress(model){ (apiResponseHandler, error) in
                    
                    self.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<MyopiaProgressResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let data = response.listMyopia {
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(MyopiaProgressList.self)) // clear old one
                                }
                                
                                for listMyopiaData in data {
                                    if let myopiaData = listMyopiaData.myopiaProgressList {
                                        
                                        var updatedMyopiaData:[MyopiaProgressList] = []
                                        
                                        for a in myopiaData {
                                            a.leftEyeValue = "0"
                                            a.rightEyeValue = "0"
                                            
                                            if let obj = ListEyeDegrees.getEyeDegreeValueById(a.leftEye) { // a.leftEye is ID. Not value
                                                a.leftEyeValue = obj.EyeDegreeValue
                                            }
                                            if let obj = ListEyeDegrees.getEyeDegreeValueById(a.rightEye) { // a.leftEye is ID. Not value
                                                a.rightEyeValue = obj.EyeDegreeValue
                                            }
                                            updatedMyopiaData.append(a)
                                        }
                                        
                                        try! realm.write {
                                            realm.add(updatedMyopiaData) // add new one
                                        }
                                    }
                                }
                                
                                completed(data.count > 0)
                                return
                            }
                            
                        }
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(), apiResponseHandler.errorCode!)
                        log.warning("Failed Getting Progress")
                        // TODO: handle failure problem
                    }
                }
            }
        }
    }
    
    func getMyopiaProgressSummary(completed: @escaping ((_ hasMyopiaProgressRecords:Bool ) -> Void), failure: @escaping (_ errorMessage : String, _ errorCode: UInt) -> Void) {
        
        if let profile = ProfileData.getProfileObj() {
            
            let model =  MyopiaProgressSummaryRequest()
            model.email = profile.email
            model.childID = childID
            model.accessToken = profile.accessToken
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                ParentApiManager.sharedInstance.getMyopiaProgressSummary(model, completed: {[weak self](apiResponseHandler, error) in
                    
                    self?.afterApiCall?()
                    
                    if apiResponseHandler.isSuccess() {
                        
                        if let response = Mapper<MyopiaProgressSummaryResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                            
                            if let data = response.listMyopia {
                                
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.delete(realm.objects(MyopiaProgressSummary.self)) // clear old one
                                }
                                
                                var updatedMyopiaData:[MyopiaProgressSummary] = []
                                
                                for a in data {
                                    a.leftEyeValue = "0"
                                    a.rightEyeValue = "0"
                                    
                                    if let obj = ListEyeDegrees.getEyeDegreeValueById(a.leftEye) { // a.leftEye is ID. Not value
                                        a.leftEyeValue = obj.EyeDegreeValue
                                    }
                                    if let obj = ListEyeDegrees.getEyeDegreeValueById(a.rightEye) { // a.leftEye is ID. Not value
                                        a.rightEyeValue = obj.EyeDegreeValue
                                    }
                                    updatedMyopiaData.append(a)
                                }
                                
                                try! realm.write {
                                    realm.add(updatedMyopiaData) // add new one
                                }
                                
                                print("Updated Myopia Data : \(updatedMyopiaData)")
                                
                                completed(data.count > 0)
                                return
                            }
                            
                        }
                        
                    }else{
                        
                        failure(apiResponseHandler.errorMessage(), apiResponseHandler.errorCode!)
                        log.warning("Failed Getting Progress Summary")
                        // TODO: handle failure problem
                    }
                })
            }
        }
    }
    
    func updateMyopiaProgress(success: @escaping (_ validationObj: ValidationObj) -> Void, failure: @escaping (_ validationObj: ValidationObj, _ errorCode: UInt) -> Void) {
        
        guard isValid else {
            log.error("This myopia progress is not valid")
            return
        }
        
        var progressUpdateDate = ""
        
        if let updatedDate = pickedDate {
            progressUpdateDate = updatedDate.toStringWith(format: "YYYY-MM-dd")
        }
        
        if let profile = ProfileData.getProfileObj() {
            
            let model = MyopiaProgressData()
            model.childID = childID
            model.accessToken = profile.accessToken
            model.email = profile.email
            model.leftEye = (selectedLeftEye?.EyeDegreeID)!
            model.rightEye = (selectedRightEye?.EyeDegreeID)!
            model.date = progressUpdateDate
            
            if ReachabilityUtil.shareInstance.isOnline(){
                
                beforeApiCall?() // before hook. can perform UI related stuff like showing HUD
                
                ParentApiManager.sharedInstance.updateMyopiaProgress(model, completed: {[weak self](apiResponseHandler, error) in
                    self?.afterApiCall?() // after hook. hiding HUD
                    
                    if apiResponseHandler.isSuccess() {
                        
                        success(ValidValidationObj())
                        
                    }else{
                        if let errorCode = apiResponseHandler.errorCode {
                            failure(InvalidValidationObj(ValidationError(message: apiResponseHandler.errorMessage())),errorCode)
                        }else{
                            failure(InvalidValidationObj(ValidationError(message: "Something went wrong. Please try again!".localized())),500)
                        }
                    }
                })
            }
        }
        
    }
    
}
