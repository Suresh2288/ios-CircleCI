//
//  ActiveChildProfile.swift
//  Plano
//
//  Created by Paing Pyi on 29/5/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper


class ActiveChildProfile: ChildProfile {
        
    required convenience init?(map: Map){
        self.init()
    }
    
    override func mapping(map: Map) {
    
        super.mapping(map: map)
        
//        accessToken <- map["Child_Access_Token"]
    }
    
    static func getProfileObj() -> ActiveChildProfile? {
        let realm = try! Realm()
        return realm.objects(ActiveChildProfile.self).filter("isActive = 1").first
    }
    
    override class func getChildProfileById(childId:String) -> ActiveChildProfile? {
//        guard let cid = childId else {
//            return nil
//        }
        let realm = try! Realm()
        let predicate = NSPredicate(format: "childID = %@", childId)
        return realm.objects(ActiveChildProfile.self).filter(predicate).first
    }
    
    // MARK: - Session
    
    func resetRemainingSessionCount(){
        try! self.realm?.write {
            remainingChildSession = Constants.maximumChildSessionPerDay
        }
    }
    
    func updateRemainingSessionCount(){
        try! self.realm?.write {
            remainingChildSession = max(0, remainingChildSession-1)
        }
    }
    
    func extendChildSession(){
        try! self.realm?.write {
            remainingChildSession = 1
        }
    }
    
    func doesHaveRemainingSession() -> Bool {
        return remainingChildSession > 0
    }
    
    func updateLastSessionStopsAt(){
        try! self.realm?.write {
            lastSessionStopsAt = Date()
        }
    }

    func checkProgressScore() -> ChildSessionManager.childProgressScore? {
        let ps = progressScore
        switch ps {
        case _ where ps >= 8:
            return .positive
        case 5...7:
            return .neutral
        case 4:
            return .negative
        default:
            return nil
        }
    }

    // MARK: - Outside Safezone
    func childIsOutsideSafeZone(outside:Bool){
        try! self.realm?.write {
            childIsOutsideSafeZone = outside
        }
    }
    
    // MARK: - Eye Calibration
    
    func resetEyeCalibration(){
        try! self.realm?.write {
            remainingEyeCalibration = Constants.maximumEyeCalibrationPerDay
        }
    }
    
    func updateEyeCalibrationCount(){
        try! self.realm?.write {
            remainingEyeCalibration = 0
        }
    }
    
    func shouldShowEyeCalibration() -> Bool {
        return remainingEyeCalibration >= 1
    }
    
    // MARK: - Game
    
    func updateRemainingGamePlayCount(){
        try! self.realm?.write {
            // remainingGamePlayPerDay = 0 -> (Allow Users t play Games 5 Times Per day)
            remainingGamePlayPerDay = Constants.maximumGamePlayPerDay - 1
        }
    }
    func resetRemainingGamePlayCount(){
        try! self.realm?.write {
            // remainingGamePlayPerDay = Constants.maximumGamePlayPerDay ->(Allow Users t play Games 5 Times Per day)
            remainingGamePlayPerDay = 5
        }
    }
    
    func updateGamePoint(_ point:String){
        try! self.realm?.write {
            self.gamePoint = point
        }
    }
    
    // MARK: - Using Device at night
    func updateUsingDeviceAtNight(isNight:Bool) {
        try! self.realm?.write {
            usingDeviceAtNightToday = isNight
        }
    }
    
    // MARK: - Progress Score
    func resetProgressScore() {
        try! self.realm?.write {
            progressScore = Constants.childProgressScorePerDay
            displayedProgressScoreToday = true
        }
    }
    
    func updateDisplayedProgressScoreToday(displayed:Bool){
        try! self.realm?.write {
            displayedProgressScoreToday = displayed
        }
    }
    
    func updateProgressScore(_ score:Int,_ deduct:Bool) {
        try! self.realm?.write {
            if deduct {
                progressScore = max(4, progressScore - score)
            }else{
                progressScore = progressScore + score
            }
        }
    }
    
    func updateDisplayedSpeechBubbleForToday(_ displayed:Bool) {
        try! self.realm?.write {
            displayedSpeechBubbleForToday = displayed
        }
    }
}
