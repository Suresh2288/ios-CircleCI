//
//  IntroVC.swift
//  Plano
//
//  Created by Paing Pyi on 8/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper
import SwiftyUserDefaults
import ReachabilitySwift
import HTTPStatusCodes
import AlamofireObjectMapper

typealias completionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void
typealias responseCompletionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void

class APIManager {
    
    enum Router: URLConvertible {
        
        case LoginWithFacebook()
        case RegisterWithFacebook()
        case Login()
        case Register()
        case ForgetPassword()
        case GetCountries()
        case GetCities()
        
        var path: String {
            switch self {
            case .LoginWithFacebook:
                return "/Security/DoAuthenticationFacebook"
            case .RegisterWithFacebook:
                return "/Parent/CreateProfileWithFacebook"    
            case .Login:
                return "/Security/DoAuthentication"
            case .Register:
                return "/Parent/CreateProfileWithRegister"
            case .ForgetPassword:
                return "/Parent/ResetPassword"
            case .GetCountries:
                return "/Utilities/GetCountries"
            case .GetCities:
                return "/Utilities/GetCities"
            }
        }
        
        func asURL() throws -> URL {
            let url = try Constants.API.URL.asURL()
            return url.appendingPathComponent(path)
        }

    }
    
    enum ApiErrorCode: UInt {
        case Success = 0
        case ServerError = 999
        case UnAuthorized = 100 // Not authorized request
        case DuplicateSession = 101 // Other device is using this account
        case UnRegistered = 103 // Not register yet
        case UnActivated = 104 // Not activated yet
        case InvalidLogin = 105 // Email and Password mismatch.
        case ParameterMissing = 108 // Parameter doesn't fullfill.
        
        func isEqalTo(code:String) -> Bool {
            let codeInt = UInt(code)
            return self.rawValue == codeInt
        }
    }
    
    // Singleton
    static let sharedInstance = APIManager()
    
    var defaultManager: Alamofire.SessionManager!

    init() {
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            :
        ]
        
        let sessionManager = SessionManager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        self.defaultManager = sessionManager
        
    }
    
    func sendJSONRequest(method: HTTPMethod, path: URLConvertible, parameters: [String : Any]?, completed: @escaping responseCompletionHandler) {
        let headers = [
            "Authorization": getAuthorizationCode(path: path),
            "Content-Type" : "application/json"
        ]
        sendJSONRequest(method: method, path: path, parameters: parameters, encoding: JSONEncoding.default, headers: headers, completed: completed)
    }
    
    // Common JSON Request
    private func sendJSONRequest(method: HTTPMethod, path: URLConvertible, parameters: [String : Any]?, encoding: ParameterEncoding, headers: [String : String],completed: @escaping responseCompletionHandler) {
        
        defaultManager.request(path, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON { (response) in
                
                switch response.result {
                    
                case .success(let data):
                    
                    if let rsp = response.response {
                        
                        let successCode = HTTPStatusCode(rawValue: rsp.statusCode)!.isSuccess
                        
                        // Have HTTP error ?
                        if successCode {
                            
                            let json = JSON(data)
                            let error = json["Success"].boolValue
                            let errorMessage = json["Message"].stringValue
                            let errorCode = json["ErrorCode"].stringValue
                            
                            if(ApiErrorCode.ServerError.isEqalTo(code: errorCode)){
                                log.error("\(error) - \(errorMessage)")
                            }
                         
                        }
                        
                        let apiResponseHandler : ApiResponseHandler = ApiResponseHandler(json: data)
                        completed(apiResponseHandler, nil)
                        
                    }
                    
                    break
                    
                case .failure(let error):
                    
                    let apiResponseHandler:ApiResponseHandler = ApiResponseHandler(json: nil)

                    completed(apiResponseHandler, error)
                    
                    break
                    
                }
            
        }
    }
    
    private func getAuthorizationCode(path : URLConvertible) -> String {
        
        let auth = Constants.API.AUTHORIZATION
        
        return auth
    }
    
    private func showConnectionIssue(path: String, errorCode: Int, errorMessage: String) {
        
        // Only show error if Network
//        if path == API.RegisterAccount.description ||
//            path == API.Login.description ||
//            path == API.UpdatePassword.description ||
//            path == API.GetUserInfo.description ||
//            path == API.AcceptBooking.description{
//            
//            Async.main() {
//                GM.showAlert(errorMessage)
//                
//            }
//        }
        
    }
    
    private func validateResponseError (data: Dictionary<String, AnyObject>?) -> Bool {
        
        return validateResponseError(data: data, showError: true)
    }
    
    private func validateResponseError (data: Dictionary<String, AnyObject>?, showError: Bool) -> Bool {
        
        if data != nil{
            
            let json = JSON(data!)
            let errorCode = json["errorCode"].intValue
            
            // Only show Error Message if no error code
            if errorCode == 0{
                
                return true
                
            }else {
                
                if showError == true {
//                    GM.showAlert(message: json["message"].stringValue)
                }
                
                return false
            }
            
            
        }else {
            
            return false
        }
    }
    
    // MARK:
    // MARK: -- Login

    func login(data: LoginData, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.Login(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            completed(apiResponseHandler, error)
        }
    }
    
    // MARK: -- Register
    
    func registerWithEmail(_ data:RegisterData, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.Register(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    // MARK: -- Forget Password
    
    func forgetPassword(data: ForgetPW, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.ForgetPassword(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    // MARK: -- Countries/Cities

    func getCountries(completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .get, path: Router.GetCountries(), parameters: nil) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }

    func getCities(_ data:CountryData, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.GetCities(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    
}

// MARK: 

struct ApiResponseHandler {
    var success:Bool = false
    var message:String? = nil
    var errorCode:UInt? = nil
    var data:Any? = nil
    var jsonObject:Any? = nil

    init(json:Any?) {
        if let js = json {
            self.jsonObject = js
            
            let json = JSON(js)
            self.success = json["Success"].boolValue
            self.message = json["Message"].stringValue
            self.errorCode = json["ErrorCode"].uInt
            self.data = json["Data"]
        }
    }
    
    func isSuccess() -> Bool {
        return success == true
    }
    
    func errorMessage() -> String {
        guard message != nil else {
            return "Server Error"
        }
        return message!
    }
}
