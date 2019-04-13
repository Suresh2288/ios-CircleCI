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
import HTTPStatusCodes
import AlamofireObjectMapper
import RealmSwift

typealias completionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void
typealias responseCompletionHandler = (_ apiResponseHandler: ApiResponseHandler, _ error: Error?) -> Void

enum ApiErrorCode: UInt {
    case Success = 0
    case ServerError = 999
    case UnAuthorized = 100 // Not authorized request
    case DuplicateSession = 101 // Other device is using this account
    case UnRegistered = 103 // Not register yet
    case UnActivated = 104 // Not activated yet
    case InvalidLogin = 105 // Email and Password mismatch.
    case ParameterMissing = 108 // Parameter doesn't fullfill.
    case ChildModeAlreadyActive = 128 //Child mode is active now in your other device.
    
    func isEqalTo(code:String) -> Bool {
        let codeInt = UInt(code)
        return self.rawValue == codeInt
    }
    
    func isEqalTo(code:UInt) -> Bool {
        return self.rawValue == code
    }
}

class APIManager {
    
    enum Router: URLConvertible {
        
        case GetMasterData()
        case GetVersionData()
        case UpdateLanguage()
        case LoginWithFacebook()
        case CheckAccountBeforeRegister()
        case LinkwithFacebook()
        case RegisterWithFacebook()
        case Login()
        case Register()
        case ForgetPassword()
        case ChangePassword()
        case GetCountries()
        case GetCities()
        case GetProfile()
        case UpdateProfile()
        case UpdateDeviceInfo()
        
        // MARK: - Parent
        case GetiOSRatingApp()
        case GetChildProfiles()
        case GetChildProfile()
        case GetChildMyopiaProgress()
        case UpdateChildMyopiaProgress()
        case CreateChildProfile()
        case UpdateChildProfile()
        case UpdateForceQuit()
        case UpdateProgress()
        case UpdateChildAccountStatus() // to soft-delete child account
        case GetPlanoPoints()
        case UpdatePairsGameResults()
        case UpdateEyexceriseGameResults()
        case UpdateChildSessionCount()
        case GetChildSessionCount()
        case UpdateChildGameRequest()
        case GetChildPlanoPoints()
        case UpdateScreenTime()
        case UpdateBreakSessionExtension()
        case GetChildEyeHealth()
        case GetChildEyeCheck()
        case CheckUserStatus()
        case CheckNtucUserNric()
        case InsertNtucUserNric()
        case UpdateNtucLinkPointsTransaction()
        case ResetChildModePrompt()
        
        // Progress
        case GetProgress()
        case GetTimeUsage()
        case GetRewards()
        case GetLastMyopiaAndReports()
        case UpdateReports()
        
        // Settings
        case GetCustomiseSettingsSummary()
        case UpdateScheduleActive()
        case UpdateBlockAppActive()
        case UpdateBlockBrowserActive()
        case UpdateLocationActive()
        case UpdateLock()
        
        // Customise Settings
        case GetChildCustomiseSettings()
        case GetCustomiseSettings()
        case UpdateCustomiseSettings()
        case CreateSchedule()
        case DeleteSchedule()
        case CreateLocation()
        case DeleteLocation()
        case UpdateSchedule()
        case UpdateLocation()
        case UpdateBlockSubLocationActive()
        case UpdateBlockSubScheduleActive()
        case UpdateBlockAppiOS()
        
        // Parent Alert Settings
        case GetAlertSettings()
        case UpdateAlertSettings()
        
        // Linked Accounts
        case GetLinkedAccounts()
        case GetPendingLinkAccount()
        case UpdateLinkedAccount()
        case RejectPendingLink()
        case CreateLinkAccount()
        case UpdateRequestLink()
        
        // Parent Wallet
        case GetAllProductForParent()
        case GetParentProductDetail()
        case UpdatePurchaseProduct()
        
        // Logout
        case DoLogout()
        
        // MARK: - Child
        // Shop
        case GetAllProductForChild()
        case GetChildProductDetail()
        case UpdateChildRequestProduct()
        case GetShopBanner()
        case GetFeaturedProducts()
        case GetParentPaymentInfo()
        case GetPaymentSettings()
        case GetProductOrders()
        case GetProductOrderDetails()
        
        // Child Dashboard
        // Switch Mode
        case SwitchChildMode()
        case SwitchParentMode()
        case GetAllGameItems()
        case UpdateAddNewGameItem()
        case UpdateGameItemStatus()
        case CheckParentPassword()
        case UpdateLocationOutPush()
        case UpdateEyeCalibration()
        case UpdateBehaviourEyeCalibration()
        case UpdatePosture()
        case GetGameBestTime()
        case ChildLogOut()
        
        // Menu
        case GetFAQs()
        case UpdateFeedback()
        case GetPolicy()
        case GetListNotification()
        case UpdateNotiSeen()
        case GetAllPremium()
        case GetAllCategories()
        case GetCurrentSubscription()
        case GetAvailableSubscriptions()
        
        // iAP
        case UpdateIOSPremium()
        
        //Myopia Summary
        case GetMyopiaSummary()
        
        
        var path: String {
            switch self {
            case .GetMasterData:
                return "/Utilities/GetMasterData"
            case .GetVersionData:
                return "/Utilities/GetVersionData"
            case .UpdateLanguage:
                return "/Utilities/UpdateLanguage"
            case .LoginWithFacebook:
                return "/Security/DoAuthenticationFacebook"
            case .CheckAccountBeforeRegister:
                return "/Parent/CheckAccountBeforeRegister"
            case .LinkwithFacebook:
                return "/Parent/LinkwithFacebook"
            case .RegisterWithFacebook:
                return "/Parent/CreateProfileWithFacebook"    
            case .Login:
                return "/Security/DoAuthentication"
            case .UpdateDeviceInfo:
                return "/Security/UpdateDeviceInfo"
            case .Register:
                return "/Parent/CreateProfileWithRegister"
            case .ForgetPassword:
                return "/Parent/ResetPassword"
            case .ChangePassword:
                return "/Parent/ChangePassword"
            case .GetProfile:
                return "Parent/GetProfile"
            case .UpdateProfile:
                return "Parent/UpdateProfile"
            case .GetiOSRatingApp:
                return "Parent/GetiOSRatingApp"
            case .GetCountries:
                return "/Utilities/GetCountries"
            case .GetCities:
                return "/Utilities/GetCities"
            case .GetChildProfiles:
                return "/Child/GetChildProfile"
            case .GetChildProfile:
                return "/Child/GetOneChildProfile"
            case .GetChildMyopiaProgress:
                return "/Parent/GetMyopiaProgress"
            case .UpdateChildMyopiaProgress:
                return "/Parent/UpdateMyopiaProgress"
            case .CreateChildProfile:
                return "/Child/CreateChildProfile"
            case .UpdateChildProfile:
                return "/Child/UpdateChildProfile"
            case .UpdateForceQuit:
                return "/Behaviour/Child/UpdateForceQuit"
            case .UpdatePairsGameResults:
                return "/Behaviour/Child/UpdatePlanoPairsGameResult"
            case .UpdateEyexceriseGameResults:
                return "/Behaviour/Child/UpdateEyexceriseGameResult"
            case .UpdateProgress:
                return "/Child/UpdateProgress"
            case .GetChildSessionCount:
                return "/Behaviour/Child/GetSessionCount"
            case .UpdateChildSessionCount:
                return "/Behaviour/Child/UpdateSessionCount"
            case .UpdateChildGameRequest:
                return "/Wallet/Child/UpdateChildGameRequest"
            case .GetCustomiseSettingsSummary:
                return "/Parent/GetCustomiseSettingsSummary"
            case .GetProgress:
                return "/Parent/GetProgress"
            case .GetTimeUsage:
                return "/Parent/GetTimeUsage"
            case .SwitchChildMode:
                return "Security/SwitchChildMode"
            case .CheckParentPassword:
                return "/Security/CheckParentPassword"
            case .SwitchParentMode:
                return "Security/SwitchParentMode"
            case .UpdateScheduleActive:
                return "/Parent/UpdateSchduleActive"
            case .UpdateBlockAppActive:
                return "/Parent/UpdateBlockAppActive"
            case .UpdateBlockBrowserActive:
                return "/Parent/UpdateBlockBrowserActive"
            case .UpdateLocationActive:
                return "/Parent/UpdateLocationActive"
            case .UpdateLock:
                return "/Parent/UpdateLock"
            case .GetAllProductForParent:
                return "/Parent/GetAllProductForParent"
            case .GetParentProductDetail:
                return "/Parent/GetProductDetail"
            case .UpdatePurchaseProduct:
                return "/Parent/UpdatePurchaseProduct"
            case .DoLogout:
                return "/Security/DoLogout"
            case .GetAllProductForChild:
                return "/Child/GetAllProductForChild"
            case .GetChildProductDetail:
                return "/Child/GetProductDetail"
            case .GetShopBanner:
                return "/Parent/GetShopBanner"
            case .GetFeaturedProducts:
                return "/Parent/GetFeaturedProducts"
            case .GetParentPaymentInfo:
                return "/Payment/GetParentPaymentInfo"
            case .GetPaymentSettings:
                return "/Payment/GetPaymentSettings"
            case .GetProductOrders:
                return "/Payment/GetProductOrders"
            case .GetProductOrderDetails:
                return "/Payment/GetProductOrderDetails"
            case .UpdateChildRequestProduct:
                return "/Wallet/Child/UpdateChildRequestProduct"
            case .GetAllGameItems:
                return "/Child/GetAllGameItems"
            case .UpdateAddNewGameItem:
                return "/Wallet/Child/UpdateAddNewGameItem"
            case .UpdateGameItemStatus:
                return "/Child/UpdateGameItemStatus"
            case .UpdateLocationOutPush:
                return "/Child/UpdateLocationOutPush"
            case .GetAlertSettings:
                return "/Parent/GetAlertSettings"
            case .UpdateAlertSettings:
                return "/Parent/UpdateAlertSettings"
            case .GetLinkedAccounts:
                return "/Parent/GetLinkedAccounts"
            case .GetPendingLinkAccount:
                return "/Parent/GetPendingLinkAccount"
            case .UpdateLinkedAccount:
                return "/Parent/UpdateLinkedAccount"
            case .RejectPendingLink:
                return "/Parent/RejectPendingLink"
            case .CreateLinkAccount:
                return "/Parent/CreateLinkAccount"
            case .UpdateRequestLink:
                return "/Parent/UpdateRequestLink"
            case .GetRewards:
                return "/Parent/GetRewards"
            case .GetCustomiseSettings:
                return "/Parent/GetCustomiseSettings"
            case .GetChildCustomiseSettings():
                return "/Child/GetChildCustomiseSettings"
            case .UpdateCustomiseSettings:
                return "/Parent/UpdateCustomiseSettings"
            case .CreateSchedule:
                return "/Parent/CreateSchedule"
            case .DeleteSchedule:
                return "/Parent/DeleteSchedule"
            case .CreateLocation:
                return "/Parent/CreateLocation"
            case .DeleteLocation:
                return "/Parent/DeleteLocation"
            case .UpdateSchedule:
                return "/Parent/UpdateSchedule"
            case .UpdateLocation:
                return "/Parent/UpdateLocation"
            case .GetFAQs:
                return "/Utilities/GetFAQs"
            case .GetPolicy:
                return "/Utilities/GetPolicy"
            case .UpdateFeedback:
                return "/Utilities/UpdateFeedback"
            case .GetListNotification:
                return "/Parent/GetListNotification"
            case .UpdateNotiSeen:
                return "/Parent/UpdateNotiSeen"
            case .GetAllPremium:
                return "/Parent/GetAllPremium"
            case .GetAllCategories:
                return "/Utilities/GetAllCategories"
            case .GetLastMyopiaAndReports:
                return "/Parent/GetLastMyopiaAndReports"
            case .UpdateReports:
                return "/Parent/UpdateReports"
            case .UpdateIOSPremium:
                return "/Subscription/Ios/UpdatePremium"
            case .UpdateBlockSubScheduleActive:
                return "/Parent/UpdateBlockSubScheduleActive"
            case .UpdateBlockSubLocationActive:
                return "/Parent/UpdateBlockSubLocationActive"
            case .UpdateBlockAppiOS:
                return "/Parent/UpdateBlockAppiOS"
            case .UpdateEyeCalibration:
                return "Child/UpdateEyeCalibration"
            case .UpdateBehaviourEyeCalibration:
                return "Behaviour/Child/UpdateEyeCalibration"
            case .UpdatePosture:
                return "Parent/UpdatePosture"
            case .GetGameBestTime:
                return "Child/GetGameBestTime"
            case .ChildLogOut:
                return "/Security/DoChildLogout"
            case .GetMyopiaSummary:
                return "/Parent/GetMyopiaSummary"
            case .UpdateChildAccountStatus:
                return "/Parent/UpdateChildAccountStatus"
            case .GetPlanoPoints:
                return "/Wallet/Parent/GetPlanoPoints"
            case .GetChildPlanoPoints:
                return "/Wallet/Child/GetPlanoPoints"
            case .UpdateScreenTime:
                return "/Behaviour/Child/UpdateScreenTime"
            case .UpdateBreakSessionExtension:
                return "/Behaviour/Child/UpdateBreakSessionExtension"
            case .GetChildEyeHealth:
                return "/Parent/Progress/GetChildEyeHealth"
            case .GetChildEyeCheck:
                return "/Parent/Progress/GetChildEyeCheck"
            case .GetCurrentSubscription:
                return "/Subscription/Ios/GetCurrentSubscription"
            case .GetAvailableSubscriptions:
                return "/Subscription/Ios/GetAvailableSubscriptions"
            case .CheckUserStatus:
                return "/ThirdParty/LinkPoints/CheckUserStatus"
            case .CheckNtucUserNric:
                return "/ThirdParty/LinkPoints/CheckNtucUserNric"
            case .InsertNtucUserNric:
                return "/ThirdParty/LinkPoints/InsertNtucUserNric"
            case .UpdateNtucLinkPointsTransaction:
                return "/ThirdParty/LinkPoints/UpdateNtucLinkPointsTransaction"
            case .ResetChildModePrompt:
                return "/Security/ResetChildModePrompt"
            }
        }
        
        func asURL() throws -> URL {
            let url = try Constants.API.URL.asURL()
            return url.appendingPathComponent(path)
        }

    }
    
    // Singleton
    static let sharedInstance = APIManager()
    
    var defaultManager: Alamofire.SessionManager!
    
    // Exception url will not be checked for Error
    var exceptions:[Router] = [.GetVersionData(),.Login(),.Register(),.ForgetPassword()]

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
        
//        var updatedParams = parameters
//        if updatedParams != nil {
//            if let profile = ProfileData.getProfileObj() {
//                updatedParams!["Access_token"] = profile.accessToken
//            }
//        }

        let updatedParams = parameters
        
        sendJSONRequest(method: method, path: path, parameters: updatedParams, encoding: JSONEncoding.default, headers: headers, completed: completed)
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
                                
                            }else if(
                                    ApiErrorCode.UnAuthorized.isEqalTo(code: errorCode) ||
                                    ApiErrorCode.DuplicateSession.isEqalTo(code: errorCode) ||
                                    ApiErrorCode.UnRegistered.isEqalTo(code: errorCode)
                                ){
                                
                                var thisUrlIsFoundInException = false
                                
                                for p in self.exceptions {
                                    
                                    do {
                                        
                                        let url1 = try p.asURL().absoluteString
                                        let url2 = try path.asURL().absoluteString
                                        if url1 == url2 {
                                            thisUrlIsFoundInException = true
                                            break
                                        }
                                        
                                    }catch {
                                        // error
                                    }
                                }
                                
                                if !thisUrlIsFoundInException {
                                    
                                    // logout user
                                    ProfileData.clearProfileData()
                                    Defaults[.childAccessToken] = nil

                                    LanguageManager.sharedInstance.resetLanguageToDefault()
                                    
                                    // clear child sessions in case if we are foced out of Child screen
                                    ChildSessionManager.sharedInstance.destroyAllSessionsWithoutChildSession()
                                    
                                    // bring to login screen
                                    if let window = UIApplication.shared.keyWindow {
                                        let nav = UIStoryboard.AuthNav()
                                        let vcs = nav.viewControllers
                                        if vcs.count > 0 {
                                            if let vc = vcs[0] as? _BaseViewController {
                                                vc.perform(#selector(vc.showAlert(_:)), with: errorMessage, afterDelay: 1)
                                            }
                                        }
                                        window.rootViewController = nav
                                    }
                                }
                                
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
    
    // MARK: -- MasterData
    
    func updateLanguage(data: UpdateLanguageRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.UpdateLanguage(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func getMasterData(data: MasterDataRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.GetMasterData(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            if let response = Mapper<MasterDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                
                let realm = try! Realm()

                // clear old data first
                try! realm.write {
                    realm.delete(realm.objects(SplashAdvertising.self)) // clear old one
                }

                if let data = response.schoolGrade {
                    try! realm.write {
                        realm.delete(realm.objects(SchoolGrade.self)) // clear old one
                        realm.add(data) // add new one
                    }
                }
                
                if let data = response.listLanguages {
                    try! realm.write {
                        realm.delete(realm.objects(Listlanguages.self)) // clear old one
                        realm.add(data) // add new one
                    }
                }


                if let data = response.splashAdvertising {
                    try! realm.write {
                        realm.add(data) // add new one
                    }
                }
                
                if let data = response.listEyeDegrees {
                    try! realm.write {
                        realm.delete(realm.objects(ListEyeDegrees.self)) // clear old one
                        realm.add(data) // add new one
                    }
                }
                
                if let data = response.currentPremiumID {
                    
                    if !Defaults.hasKey(.currentPremiumID) {
                        Defaults.remove(.currentPremiumID)
                    }
                    
                    Defaults[.currentPremiumID] = data
                }
            }
            
            completed(apiResponseHandler, error)
        }
    }
    
    func getVersionData(completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .get, path: Router.GetVersionData(), parameters: nil) { (apiResponseHandler, error) -> Void in
            
            if let response = Mapper<VersionDataResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                
                let realm = try! Realm()
                
                // clear old data first
                try! realm.write {
                    realm.delete(realm.objects(ForceUpdate.self)) // clear old one
                }

                if let data = response.forceUpdate {
                    try! realm.write {
                        realm.add(data) // add new one
                    }
                }
            }
            
            completed(apiResponseHandler, error)
        }
    }
    
    // MARK: -- Login

    func login(data: LoginData, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.Login(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            completed(apiResponseHandler, error)
        }
    }

    func loginWithFacebook(data: FacebookLoginData, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.LoginWithFacebook(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            completed(apiResponseHandler, error)
        }
    }

    func checkAccountBeforeRegister(data: CheckAccountBeforeRegisterRequest, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.CheckAccountBeforeRegister(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }

    func updateDeviceInfo(data: UpdateDeviceInfoRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.UpdateDeviceInfo(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    

    // MARK: -- Register
    
    func registerWithEmail(_ data:RegisterData, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.Register(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            print("data.toJSON():\(data.toJSON())")
            print("apiResponseHandler.jsonObject:\(String(describing: apiResponseHandler.jsonObject))")
            completed(apiResponseHandler, error)
        }
    }

    func registerWithFacebook(_ data:RegisterData, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.RegisterWithFacebook(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            completed(apiResponseHandler, error)
        }
    }

    func linkWithFacebook(_ data:LinkwithFacebookRequest, completed: @escaping completionHandler) {

        sendJSONRequest(method: .post, path: Router.LinkwithFacebook(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in

            completed(apiResponseHandler, error)
        }
    }

    
    func getProfile(_ data:GetProfileRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.GetProfile(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func updateProfile(_ data:UpdateProfileRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.UpdateProfile(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    
    func resetPassword(_ data:ResetPasswordRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.ChangePassword(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
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

    func getCities(_ data:CityDataRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.GetCities(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
            completed(apiResponseHandler, error)
        }
    }
    
    func getAllCategories(_ data:GetAllCategoriesRequest, completed: @escaping completionHandler) {
        
        sendJSONRequest(method: .post, path: Router.GetAllCategories(), parameters: data.toJSON()) { (apiResponseHandler, error) -> Void in
            
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
            self.errorCode = UInt(json["ErrorCode"].intValue)
            self.data = json["Data"]
        }
    }
    
    func isSuccess() -> Bool {
        return success == true
    }
    
    func errorMessage() -> String {
        guard message != nil else {
            return "Unknown Error Occurred"
        }
        return message!
    }
}
