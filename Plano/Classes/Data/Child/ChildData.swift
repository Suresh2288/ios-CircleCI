//
//  ChildData.swift
//  Plano
//
//  Created by Paing Pyi on 25/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyUserDefaults
import SwiftDate

class ChildProfile: Object, Mappable {
    
    @objc dynamic var childID = ""
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var dob:Date?
    @objc dynamic var gender = ""
    @objc dynamic var eyeTest = ""
    @objc dynamic var isWearingGlass = ""
    @objc dynamic var glassStartYear = ""
    @objc dynamic var glassStartMonth = ""
    @objc dynamic var eyeCheckYear = ""
    @objc dynamic var eyeCheckMonth = ""
    @objc dynamic var leftEyeBefore = ""
    @objc dynamic var rightEyeBefore = ""
    @objc dynamic var leftEye = ""
    @objc dynamic var rightEye = ""
    @objc dynamic var infoBased = ""
    @objc dynamic var profileImage = ""
    @objc dynamic var gamePoint = ""
    @objc dynamic var sessionNumber = ""
    @objc dynamic var isEyeTested = ""
    @objc dynamic var gameType = ""
    @objc dynamic var durationSeconds = ""
    @objc dynamic var timeDifference = ""
    @objc dynamic var deviceType = ""
    @objc dynamic var deviceID = ""
    
    @objc dynamic var accessToken:String?
    @objc dynamic var progressScore:Int = 0
    @objc dynamic var remainingChildSession:Int = 0
    @objc dynamic var remainingEyeCalibration:Int = 0
    @objc dynamic var remainingGamePlayPerDay:Int = 0
    @objc dynamic var usingDeviceAtNightToday:Bool = false
    @objc dynamic var lastSessionStopsAt:Date?
    @objc dynamic var isActive:Bool = false
    @objc dynamic var childIsOutsideSafeZone:Bool = false
    @objc dynamic var displayedSpeechBubbleForToday:Bool = false
    @objc dynamic var displayedProgressScoreToday:Bool = false
    
    required convenience init?(map: Map){
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "childID"
    }

    func mapping(map: Map) {
        
        childID <- map["ChildID"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        dob <- (map["DOB"], CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        gender <- map["Gender"]
        eyeTest <- map["EyeTest"]
        isWearingGlass <- map["Wearing_Glass"]
        glassStartYear <- map["Glass_Start_Year"]
        glassStartMonth <- map["Glass_Start_Month"]
        eyeCheckYear <- map["Last_Eyecheck_Age_Year"]
        eyeCheckMonth <- map["Last_Eyecheck_Age_Month"]
        leftEyeBefore <- map["StartedLeftEye"]
        rightEyeBefore <- map["StartedRightEye"]
        leftEye <- map["LeftEye"]
        rightEye <- map["RightEye"]
        infoBased <- map["InfoBased"]
        profileImage <- map["Profile_Image"]
        gamePoint <- map["GamePoint"]
    }
    
    func getGenderMaleBool() -> Bool {
        return gender.caseInsensitiveCompare("true") == .orderedSame
    }
    
    
    func didEyeTested() -> Bool? {
        if !eyeTest.isEmpty {
            return eyeTest.caseInsensitiveCompare("true") == .orderedSame
        }else{
            return nil
        }
    }
    
    func getWearingGlassBool() -> Bool? {
        if !isWearingGlass.isEmpty {
            return isWearingGlass.caseInsensitiveCompare("true") == .orderedSame
        }else{
            return nil
        }
    }
    
    func getInfoBasedInInt() -> InfoBased? {
        if !infoBased.isEmpty {
            if infoBased.caseInsensitiveCompare(InfoBased.prescription.rawValue) == .orderedSame {
                return .prescription
            }else{
                return .memory
            }
        }else{
            return nil
        }
    }
    
    func getEyeDegreeByID(_ eid:String) -> ListEyeDegrees? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "EyeDegreeID = %@", eid)
        return realm.objects(ListEyeDegrees.self).filter(predicate).first
    }

    static func getChildProfiles() -> Results<ChildProfile>{
        let realm = try! Realm()
        return realm.objects(ChildProfile.self)
    }
    
    class func getChildProfileById(childId:String) -> ChildProfile? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "childID = %@", childId)
        return realm.objects(ChildProfile.self).filter(predicate).first
    }
    
    static func isLessThanDOB(inputDate : Date?, childID : String) -> Bool{
        if let profile = getChildProfileById(childId: childID), let dob = profile.dob {
            if let myopiaDate = inputDate {
                if myopiaDate < dob && myopiaDate < Date(){
                    return true
                }
            }
            
        }
        return false
    }
    
}

class ChildProfilesResponse: NSObject, Mappable {
    
    @objc dynamic var profiles: [ChildProfile]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profiles <- map["Data.profile"]
    }
    
}


class ChildProfileRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(email: String, accessToken: String) {
        
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class ChildEyeHealthRequest: NSObject, Mappable {
    
    var email = ""
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, childId: String, accessToken: String) {
        self.childId = childId
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

class ChildEyeHealthResponse: NSObject, Mappable {
    
    @objc dynamic var DigitalEyeBehaviour:Int = 0
    @objc dynamic var DigitalEyeStrain:Int = 0
    @objc dynamic var DigitalEyeBehaviourGoal:Int = 0
    @objc dynamic var DigitalEyeStrainGoal:Int = 0
    @objc dynamic var PlanoPoints:Int = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        DigitalEyeBehaviour <- map["Data.DigitalEyeBehaviour"]
        DigitalEyeStrain <- map["Data.DigitalEyeStrain"]
        DigitalEyeBehaviourGoal <- map["Data.DigitalEyeBehaviourGoal"]
        DigitalEyeStrainGoal <- map["Data.DigitalEyeStrainGoal"]
        PlanoPoints <- map["Data.PlanoPoints"]
    }
    
}

class ChildEyeCheckRequest: NSObject, Mappable {
    
    var email = ""
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, childId: String, accessToken: String) {
        self.childId = childId
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

class ChildEyeCheckResponse: NSObject, Mappable {
    
    @objc dynamic var PreviousEyeVisitDate:String = ""
    @objc dynamic var UpcomingEyeVisitDate:String = ""
    @objc dynamic var WarningLevel:String = ""
    @objc dynamic var Description:String = ""
    @objc dynamic var IsShowMessage:String = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        PreviousEyeVisitDate <- map["Data.PreviousEyeVisitDate"]
        UpcomingEyeVisitDate <- map["Data.UpcomingEyeVisitDate"]
        WarningLevel <- map["Data.WarningLevel"]
        Description <- map["Data.Description"]
        IsShowMessage <- map["Data.IsShowMessage"]
    }
    
}

class GetChildSessionResponse: NSObject, Mappable {
    
    @objc dynamic var ChildSessionCount:Int = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        ChildSessionCount <- map["Data.ChildSessionCount"]
    }
    
}

class UpdateChildSessionRequest: NSObject, Mappable {
    
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var deviceType = "iOS"
    var deviceID = Defaults[.pushToken]
    var timeDifference = ""
    
    required init?(map: Map) {
        
    }
    
    init(childId: String, accessToken: String, deviceType: String, deviceID: String, timeDifference: String) {
        self.childId = childId
        self.accessToken = accessToken
        self.deviceType = deviceType
        self.deviceID = deviceID
        self.timeDifference = timeDifference
    }
    
    func mapping(map: Map) {
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        deviceType <- map["device_Type"]
        deviceID <- map["device_ID"]
        timeDifference <- map["timeDifference"]
        languageID <- map["LanguageID"]
    }
}

class GetChildSessionRequest: NSObject, Mappable {
    
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var timeDifference = ""
    
    required init?(map: Map) {
        
    }
    
    init(childId: String, accessToken: String, timeDifference: String) {
        self.childId = childId
        self.accessToken = accessToken
        self.timeDifference = timeDifference
    }
    
    func mapping(map: Map) {
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        timeDifference <- map["timeDifference"]
        languageID <- map["LanguageID"]
    }
}

class UpdateScreenTimeRequest: NSObject, Mappable {
    
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var sessionNumber = ""
    var durationSeconds = ""
    
    required init?(map: Map) {
        
    }
    
    init(childId: String, accessToken: String, durationSeconds: String, sessionNumber: String) {
        self.childId = childId
        self.accessToken = accessToken
        self.sessionNumber = sessionNumber
        self.durationSeconds = durationSeconds
    }
    
    func mapping(map: Map) {
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        sessionNumber <- map["sessionNumber"]
        durationSeconds <- map["durationSeconds"]
        languageID <- map["LanguageID"]
    }
}

class UpdateSessionBreakTimeRequest: NSObject, Mappable {
    
    var childId = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    var sessionNumber = ""
    var durationSeconds = ""
    
    required init?(map: Map) {
        
    }
    
    init(childId: String, accessToken: String, durationSeconds: String, sessionNumber: String) {
        self.childId = childId
        self.accessToken = accessToken
        self.sessionNumber = sessionNumber
        self.durationSeconds = durationSeconds
    }
    
    func mapping(map: Map) {
        childId <- map["childID"]
        accessToken <- map["Access_Token"]
        sessionNumber <- map["sessionNumber"]
        durationSeconds <- map["extensionSeconds"]
        languageID <- map["LanguageID"]
    }
}

class ChildSingleProfileRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(childID: String, accessToken: String) {
        
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class ChildSingleProfileResponse: NSObject, Mappable {
    
    @objc dynamic var profile: ActiveChildProfile?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        profile <- map["Data.profile"]
    }
    
}

class AddChildData: NSObject, Mappable {
    
    var accessToken = ""
    var childID:String?
    var parentEmail:String?
    var firstName = ""
    var lastName = ""
    var dob = ""
    var gender:Bool = true
    var eyeTest:Bool?
    var wearingGlasses:Bool?
    var glassStartYear:String?
    var glassStartMonth:String?
    var eyeCheckYear:String?
    var eyeCheckMonth:String?
    var leftEyeBefore:String?
    var rightEyeBefore:String?
    var leftEye:String?
    var rightEye:String?
    var infoBased:String?
    var profileImage:String = "0"
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        
        accessToken <- map["Access_Token"]
        childID <- map["ChildID"]
        parentEmail <- map["ParentEmail"]
        firstName <- map["First_Name"]
        lastName <- map["Last_Name"]
        dob <- map["DOB"]
        gender <- map["Gender"]
        eyeTest <- map["EyeTest"]
        wearingGlasses <- map["Wearing_Glass"]
        glassStartYear <- map["Glass_Start_Year"]
        glassStartMonth <- map["Glass_Start_Month"]
        eyeCheckYear <- map["Last_Eyecheck_Age_Year"]
        eyeCheckMonth <- map["Last_Eyecheck_Age_Month"]
        leftEyeBefore <- map["StartedLeftEye"]
        rightEyeBefore <- map["StartedRightEye"]
        leftEye <- map["LeftEye"]
        rightEye <- map["RightEye"]
        infoBased <- map["InfoBased"]
        profileImage <- map["Profile_Image"]
        languageID <- map["LanguageID"]

    }
}

class AddChildResponse: NSObject, Mappable {
    
    @objc dynamic var childID:String = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        childID <- map["Data.ChildID"]
    }
    
}



class UpdateChildPointRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(childID:String, accessToken:String) {
        
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]

    }
}

class UpdateChildPointResponse: NSObject, Mappable {
    
    @objc dynamic var point:String = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        point <- map["Data.CurrentPoint"]
    }
    
}

class UpdateChildGameRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(childID:String, accessToken:String) {
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

class UpdateChildGameResponse: NSObject, Mappable {
    
    @objc dynamic var point:String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        point <- map["Data.CurrentPoint"]
    }
    
}

class GetChildPlanoPointsRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    init(childID:String, accessToken:String) {
        self.childID = childID
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
    }
}

class GetPlanoPointsResponse: NSObject, Mappable {
    
    @objc dynamic var ChildPlanoPoint:Int = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        ChildPlanoPoint <- map["Data.ChildPlanoPoints"]
    }
    
}

class GetParentPlanoPointsRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, accessToken: String) {
        
        self.email = email
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        
    }
}

class GetParentPlanoPointsResponse: NSObject, Mappable {
    
    @objc dynamic var ParentPlanoPoint:Int = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        ParentPlanoPoint <- map["Data.ParentPlanoPoints"]
    }
    
}

class InsertNtucUserNricRequest: NSObject, Mappable {
    
    var email = ""
    var accessToken = ""
    var nric = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(email: String, nric: String, accessToken: String) {
        
        self.email = email
        self.nric = nric
        self.accessToken = accessToken
    }
    
    func mapping(map: Map) {
        email <- map["Email"]
        nric <- map["nric"]
        accessToken <- map["Access_Token"]
        languageID <- map["LanguageID"]
        
    }
}

class CheckUserStatusResponse: NSObject, Mappable {
    
    @objc dynamic var IsPaidPremiumUser:Int = 0
    var NotSubscriberNtucMessage = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        IsPaidPremiumUser <- map["Data.IsPaidPremiumUser"]
        NotSubscriberNtucMessage <- map["Data.NotSubscriberNtucMessage"]
    }
    
}

class CheckNtucUserNricResponse: NSObject, Mappable {
    
    @objc dynamic var IsNtucUserNricExist:Int = 0
    @objc dynamic var NtucLinkpointsCredit:Int = 0
    @objc dynamic var PlanoPointsDebit:Int = 0
    var NtucPlusUrl = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        IsNtucUserNricExist <- map["Data.IsNtucUserNricExist"]
        NtucLinkpointsCredit <- map["Data.NtucLinkpointsCredit"]
        PlanoPointsDebit <- map["Data.PlanoPointsDebit"]
        NtucPlusUrl <- map["Data.NtucPlusUrl"]
    }
    
}

class UpdateChildGameResultRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var sessionNumber = ""
    var gameType = ""
    var durationSeconds = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map) {
        
    }
    
    init(childID:String, accessToken:String, updatedSeconds:String, gameType:String, sessionNumber:String) {
        self.childID = childID
        self.accessToken = accessToken
        self.sessionNumber = sessionNumber
        self.durationSeconds = updatedSeconds
        self.gameType = gameType
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        sessionNumber <- map["SessionNumber"]
        durationSeconds <- map["DurationSeconds"]
        gameType <- map["GameType"]
        languageID <- map["LanguageID"]
    }
}

class CheckParentPasswordRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var password = ""
    var email = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(childID:String, accessToken:String, password:String, email:String) {
        
        self.childID = childID
        self.accessToken = accessToken
        self.password = password
        self.email = email
    }
    
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        password <- map["Password"]
        email <- map["Email"]
        languageID <- map["LanguageID"]

    }
}

class CheckParentPasswordResponse: NSObject, Mappable {
    
    @objc dynamic var found:String = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        found <- map["Data.Found"]
    }
    
    func isFound() -> Bool {
        return found == "1"
    }
    
}



class ChildLocationOutPushRequest: NSObject, Mappable {
    
    var childID = ""
    var accessToken = ""
    var locationName = ""
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(childID:String, accessToken:String, locationName:String) {
        
        self.childID = childID
        self.accessToken = accessToken
        self.locationName = locationName
    }
    
    func mapping(map: Map) {
        childID <- map["ChildID"]
        accessToken <- map["Access_Token"]
        locationName <- map["LocationName"]
        languageID <- map["LanguageID"]

    }
}


///////


class GetAllCategoriesRequest: NSObject, Mappable {
    
    var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    override init(){
        super.init()
    }
    
    func mapping(map: Map) {
        languageID <- map["LanguageID"]
    }
}

class GetAllCategoriesResponse: NSObject, Mappable {
    
    @objc dynamic var listcategories:[AllCategories]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        listcategories <- map["Data.listcategories"]
    }
    
}

class AllCategories: Object, Mappable {
    
    @objc dynamic var CategoryID = ""
    @objc dynamic var CategoryName = ""
    
    required convenience init?(map: Map){
        self.init()
    }
    
    func mapping(map: Map) {
        CategoryID <- map["CategoryID"]
        CategoryName <- map["CategoryName"]
    }
    
    static func getAllCategories() -> Results<AllCategories>?{
        let realm = try! Realm()
        return realm.objects(AllCategories.self)
    }
    
    static func getAllCategoriesForChild() -> Results<AllCategories>?{
        let realm = try! Realm()
        return realm.objects(AllCategories.self).filter("CategoryID != '1'") // skip "Child Requested"
    }
}

///////

class UpdateProgressRequest: NSObject, Mappable {
    
    @objc dynamic var ChildID = ""
    @objc dynamic var Access_Token = ""
    @objc dynamic var Description = ""
    @objc dynamic var DeductPoint = ""
    @objc dynamic var ProgressDateTime = "" // yyyy-MM-dd hh:mm
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(ChildID : String, Access_Token : String, Description : String, DeductPoint : Int, ProgressDateTime : Date) {
        self.ChildID = ChildID
        self.Access_Token = Access_Token
        self.Description = Description
        self.DeductPoint = String(DeductPoint)
        
        // convert to UTC
        let strDate = Date().localToUTC(format: "yyyy-MM-dd HH:mm")
        self.ProgressDateTime = strDate
    }
    
    func mapping(map: Map) {
        ChildID <- map["ChildID"]
        Access_Token <- map["Access_Token"]
        Description <- map["Description"]
        DeductPoint <- map["DeductPoint"]
        ProgressDateTime <- map["ProgressDateTime"]
        languageID <- map["LanguageID"]

    }
}

////////

class UpdateEyeCalibrationRequest: NSObject, Mappable {
    @objc dynamic var ChildID = ""
    @objc dynamic var Access_Token = ""
    @objc dynamic var EyeCheck = ""
    @objc dynamic var EyeDistance = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(ChildID : String, Access_Token : String, EyeCheck : String, EyeDistance : String) {
        self.ChildID = ChildID
        self.Access_Token = Access_Token
        self.EyeCheck = EyeCheck
        self.EyeDistance = EyeDistance
    }
    
    func mapping(map: Map) {
        ChildID <- map["ChildID"]
        Access_Token <- map["Access_Token"]
        EyeCheck <- map["EyeCheck"]
        EyeDistance <- map["EyeDistance"]
        languageID <- map["LanguageID"]

    }
}

class UpdateBehaviourEyeCalibrationRequest: NSObject, Mappable {
    @objc dynamic var ChildID = ""
    @objc dynamic var Access_Token = ""
    @objc dynamic var SessionNumber = ""
    @objc dynamic var IsTested = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()
    
    required init?(map: Map){
        
    }
    
    init(ChildID : String, Access_Token : String, SessionNumber : String, IsTested : String) {
        self.ChildID = ChildID
        self.Access_Token = Access_Token
        self.SessionNumber = SessionNumber
        self.IsTested = IsTested
    }
    
    func mapping(map: Map) {
        ChildID <- map["ChildID"]
        Access_Token <- map["Access_Token"]
        SessionNumber <- map["SessionNumber"]
        IsTested <- map["IsTested"]
        languageID <- map["LanguageID"]
        
    }
}

class UpdatePostureRequest: NSObject, Mappable {
    @objc dynamic var Email = ""
    @objc dynamic var ChildID = ""
    @objc dynamic var Access_Token = ""
    @objc dynamic var PostureActive = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(Email:String, ChildID : String, Access_Token : String, PostureActive:String) {
        self.Email = Email
        self.ChildID = ChildID
        self.Access_Token = Access_Token
        self.PostureActive = PostureActive
    }
    
    func mapping(map: Map) {
        Email <- map["Email"]
        Access_Token <- map["Access_Token"]
        ChildID <- map["ChildID"]
        PostureActive <- map["PostureActive"]
        languageID <- map["LanguageID"]

    }
}

////////

class GetGameBestTimeRequest: NSObject, Mappable {
    @objc dynamic var ChildID = ""
    @objc dynamic var Access_Token = ""
    @objc dynamic var GameTime = ""
    @objc dynamic var languageID = LanguageManager.sharedInstance.getSelectedLanguageID()

    required init?(map: Map){
        
    }
    
    init(ChildID : String, Access_Token : String, GameTime : String) {
        self.ChildID = ChildID
        self.Access_Token = Access_Token
        self.GameTime = GameTime
    }
    
    func mapping(map: Map) {
        ChildID <- map["ChildID"]
        Access_Token <- map["Access_Token"]
        GameTime <- map["GameTime"]
        languageID <- map["LanguageID"]

    }
}

class GetGameBestTimeResponse: NSObject, Mappable {
    @objc dynamic var BestTimeMessage = ""
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        BestTimeMessage <- map["Data.BestTimeMessage"]
    }
}
