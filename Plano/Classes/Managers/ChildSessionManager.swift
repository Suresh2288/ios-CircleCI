//
//  ChildSessionManager.swift
//  Plano
//
//  Created by Paing Pyi on 3/6/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate
import SwiftyUserDefaults
import ObjectMapper
import RealmSwift
import UserNotifications
import Device
import CoreLocation
import UserNotifications

class ChildSessionManager : NSObject {
    
    enum childSessionStatus {
        case emptyStatus
        case deviceCanNowBeUsed
        case before30Minutes
        case fiveMinuteBefore35
        case timesUp
        case fiveMinuteAfter35
        case sixMinuteAfter35
        case dailyUsageOver
        case breakTime
        case breakTimeAfter90Sec
        case breakTimeAfter5Min
        case childOutsideSafeArea
    }
    
    enum usingDeviceAtNightStatus {
        case notNight
        case near7pm
        case duringNight
    }
    
    enum childProgressScore {
        case positive
        case neutral
        case negative
    }
    
    enum childSessionPointStatus:String {
        case text_play_game_plano_pairs = "Play game - plano pairs"
        case text_play_game_eyecerxise = "Play game - Eyexercise"
        case text_positive_progress_tracking = "Positive progress tracking - Abiding by all rules"
        case text_neutral_progress_tracking = "Neutral progress tracking - Abiding by some rules, not others"
        case text_negative_progress_tracking = "Negative progress tracking - Not following most rules"
        case text_rest_more_than_5mins_session_1 = "Session 1 - rest more than 5mins"
        case text_rest_more_than_5mins_session_2 = "Session 2 - rest more than 5mins"
        case text_rest_more_than_5mins_session_3 = "Session 3 - rest more than 5mins"
        case text_rest_more_than_5mins_session_4 = "Session 4 - rest more than 5mins"
        case text_extend_5mins_after_35mins_session_1 = "Session 1 - extend 5 mins after 35 minutes of device activity"
        case text_extend_5mins_after_35mins_session_2 = "Session 2 - extend 5 mins after 35 minutes of device activity"
        case text_extend_5mins_after_35mins_session_3 = "Session 3 - extend 5 mins after 35 minutes of device activity"
        case text_extend_5mins_after_35mins_session_4 = "Session 4 - extend 5 mins after 35 minutes of device activity"
        case text_stop_at_5_mins_pior_to_35mins_session_1 = "Session 1 - stop at 5 minutes prior to 35 mins on device"
        case text_stop_at_5_mins_pior_to_35mins_session_2 = "Session 2 - stop at 5 minutes prior to 35 mins on device"
        case text_stop_at_5_mins_pior_to_35mins_session_3 = "Session 3 - stop at 5 minutes prior to 35 mins on device"
        case text_stop_at_5_mins_pior_to_35mins_session_4 = "Session 4 - stop at 5 minutes prior to 35 mins on device"
        case text_full_session_with_device_at_correct_distance = "Full session with device at correct distance"
        case text_rest_less_than_1min_30secs_on_device = "Rest less than 1min 30secs on device"
        case text_use_after_parent_cut_off_time = "Use after parent cut-off time"
        
        case text_stop_using_device_or_lose_250 = "Come back to plano to take a break and rest your eyes now."
        case text_user_skip_eye_calibration = "User skipped eye calibration"
        case text_user_leaves_rest_screen = "User leaves rest screen and lose 250 points"
    }
    
    static let sharedInstance = ChildSessionManager()
    static let timerNotificationIdentifier:String = "timerNotificationIdentifier"
    static let childSessionTimerIdentifier:String = "CHILD_SESSION_TIMER"
    static let childSessionStartedIdentifier:String = "CHILD_SESSION_STARTED"
    static let eyeCalibrationNotiIdentifier:String = "showEyeCaliNoti"
    static let usingDeviceAtNight:String = "usingDeviceAtNight"
    static let youAreOutsideSafeArea:String = "youAreOutsideSafeArea"
    static let resetChildSessionEachDayIdentifier:String = "resetChildSessionEachDay"
    
    var activeChildProfile:ActiveChildProfile?
    var viewModel = ChildDashboardViewModel()
    
    var isSessionInit:Bool = false
    var sessionActive:Bool = false
    var breakTime:Bool = false
    var afterBreakExtension:Bool = false
    var timer:Timer?
    var dailyUsageOver:Bool = false
    var deductedPointForRestTimeGoBackground:Bool = false
    
    var sessionEndingTime:Date = Date()
    var sessionEndingBefore5Minute:Date = Date()
    var sessionEndingAfter5Minute:Date = Date()
    var sessionEndingAfter6Minute:Date = Date()
    
    let backgroundQueue: DispatchQueue? = DispatchQueue(label: "backgroundQueue", attributes: DispatchQueue.Attributes.concurrent);
    
    var after1MinuteTimer: DispatchSourceTimer? = nil; // 1 minute after session ended to deduct 50 pts.
    var after1MinuteTimerDispatchTimeIntervalSecond:Int = 0
    
    var after6MinuteTimer: DispatchSourceTimer? = nil;
    var dispatchTimeIntervalSecond:Int = 0
    
    var breakTimeTimer: DispatchSourceTimer? = nil;
    var breakTimeTimerDate:Date?
    var breakTimeAfter5Minute:Date?
    var breakTimeTimeInterval:Int = 0
    
    var needEyeCalibration1MinuteTimer: DispatchSourceTimer? = nil; // 1 minute to deduct 50 pts.
    var needEyeCalibration1MinuteDispatchTimeIntervalSecond:Int = 0
    
    var usingDeviceAtNightTimer: DispatchSourceTimer? = nil; // 1 minute to deduct 50 pts.
    var usingDeviceAtNightDispatchTimeIntervalSecond:Int = 0
    
    var appQuiteLocalNotification:UILocalNotification?
    var appQuiteTimer: DispatchSourceTimer? = nil;
    
    var resetAtMidNightNotification:UILocalNotification?
    var deviceCanNowBeUsed = false
    
    var locationManager = CLLocationManager()
    
    // MARK: - Sessions
    func startSessionIfRequired(){
        
        // clear other remaining Schedul Notifications and bg jobs
        clearQueueAndNotificationTimersAndResetEveryNightSchedule()
        
        // Rest timer at midnight
        scheduleLocalNotificationForResetAtEveryNight()
        
        // TODO: DEBUG:
        if !Constants.isProduction {
            resetRemainingSessionCount()
            resetEyeCalibration()
        }
        
        // manage SessionPerDay count
        // if there is previous session,
        // - check if it's today
        // -- if today, do nothing
        // -- if not today, we reset the counter
        //
        // if there is previous session,
        // - check if has valid session count
        //
        // if there is no previou session,
        // - can be consider as fresh install, so we just start the session
        //
        
        if let _ = getActiveChildProfile()?.lastSessionStopsAt {
            
            // reset session if it's new day
            resetChildSessionEachDayIfRequired()
            
            if !isChildInSafeZone() {
                showYouAreOutsideSafeAreaPopup()
                
            }else if doesHaveRemainingSession() {
                // continue
                sessionStarted()
            }else{
                // show popup
                showPopupIfRequired()
            }
            
        }else{
            
            // it's fresh install
            // so set max value
            resetChildSessionEachDay()
            
            sessionStarted()
        }
        
    }
    
    func resetChildSessionEachDayIfRequired(){
        if isItNewDay() {
            resetChildSessionEachDay()
        }
    }
    
    func resetChildSessionEachDayIfRequiredAndShowPopup(){
        if isItNewDay() {
            resetChildSessionEachDay()
            showPopupIfRequired()
        } else if (UserDefaults.standard.integer(forKey: "IsDeviceLocked") == 1 && CLLocationManager.locationServicesEnabled()) {
            self.ResumeTimer()
        } else if (UserDefaults.standard.integer(forKey: "IsTimerPaused") == 1) {
            self.ResumeTimer()
        }
    }
    
    func isItNewDay() -> Bool {
        let today = Date()
        if let lastSessionStopsAt = getActiveChildProfile()?.lastSessionStopsAt, lastSessionStopsAt.isInSameDayOf(date: today) == true {
            return false
        }else{
            return true
        }
    }
    
    func resetChildSessionEachDay(){
        clearAllSessions()
        
        resetRemainingSessionCount()
        resetEyeCalibration()
        resetRemainingGamePlayCount()
        resetUsingDeviceAtNightFlag()
        resetSpeechBubble()
        resetDisplayedProgressScoreFlag()
        
        deviceCanNowBeUsed = true
        sessionActive = false
        breakTime = false
        dailyUsageOver = false
        afterBreakExtension = false
        
        let timerString = "\(Constants.childSessionPeriodMinute):00"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChildSessionManager.timerNotificationIdentifier), object: timerString, userInfo: nil)
        
        // clean up the delivered notifications for user
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllDeliveredNotifications()
        }
        
        log.debug(#function)
    }
    
    func sessionStarted(){
        
        deviceCanNowBeUsed = false
        isSessionInit = true
        sessionActive = true
        
        UserDefaults.standard.remove("LastScreenTimeAt")
        UserDefaults.standard.remove("SessionStartedAt")
        UserDefaults.standard.remove("TotalLockStateTime")
        UserDefaults.standard.remove("TotalScreenTime")
        UserDefaults.standard.remove("IsDeviceLocked")
        UserDefaults.standard.remove("IsDeviceUnlocked")
        
        UserDefaults.standard.set(Date(), forKey: "SessionStartedAt")
        UserDefaults.standard.synchronize()
        
        // create 30, 35, 40 notifications
        
        /*
         **** important ****
         */
        
        if Constants.isProduction { // production session
            
            sessionEndingTime = Date() + Constants.childSessionPeriod.seconds
            
            sessionEndingBefore5Minute = sessionEndingTime - Constants.childSessionBeforeAfterGap.seconds
            sessionEndingAfter5Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGap.seconds
            sessionEndingAfter6Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGapPlus1.seconds
            
            // seconds // Deduct 50 points for continue using at 1 minute
            // 0 + 5 minutes
            after1MinuteTimerDispatchTimeIntervalSecond = Constants.childSessionPeriod + Constants.childSessionBeforeAfterGap
            
            // seconds / gap time between "Stop Now" and "-250 penalty"
            // 0 + 6 + 1 minutes
            dispatchTimeIntervalSecond = Constants.childSessionPeriod + Constants.childSessionBeforeAfterGapPlus1 + Constants.gapTimeBetweenStopNowAndPanelty
            
            breakTimeTimeInterval = Constants.breakTimeAfter5Minute // break time after 5 minute
            
            needEyeCalibration1MinuteDispatchTimeIntervalSecond = Constants.skipEyeCalibrationDeductionPointPeriod // seconds
            
        }else{ // this is for debug session
            
            sessionEndingTime = Date() + Constants.childSessionPeriodDebug.seconds
            
            sessionEndingBefore5Minute = sessionEndingTime - Constants.childSessionBeforeAfterGapDebug.seconds
            sessionEndingAfter5Minute = sessionEndingTime + Constants.childSessionBeforeAfterGapDebug.seconds
            sessionEndingAfter6Minute = sessionEndingTime + Constants.childSessionBeforeAfterGapPlus1Debug.seconds
            
            // seconds // Deduct 50 points for continue using at 1 minute
            // 0 + 5 minutes
            after1MinuteTimerDispatchTimeIntervalSecond = Constants.childSessionPeriodDebug + Constants.childSessionBeforeAfterGapDebug
            
            // gap time between "Stop Now" and "-250 penalty"
            // 0 + 6 + 1 minutes
            dispatchTimeIntervalSecond = Constants.childSessionPeriodDebug + Constants.childSessionBeforeAfterGapPlus1Debug + Constants.gapTimeBetweenStopNowAndPaneltyDebug
            
            breakTimeTimeInterval = Constants.breakTimeAfter5MinuteDebug // break time after 5 minute
            
            needEyeCalibration1MinuteDispatchTimeIntervalSecond = Constants.skipEyeCalibrationDeductionPointPeriodDebug // seconds
            
        }
        
        // reduce 1 count from 4 sessions
        updateRemainingSessionCount()
        
        // local notification
        initLocalNotification()
        
        //---------------------
        // start countdown to 35
        if let tm = timer {
            tm.invalidate()
        }
        isTimerUp(timer: nil) // need to manual start the `isTimerUp` not to lose 1|2 seconds
        // this line execute after 1 seconds because we give `timeInterval` to 1 -- meaning it will start calling `isTimerUp` after 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(isTimerUp), userInfo: nil, repeats: true)
        //---------------------
        
        // delay.. pushing out Noti because `ChildDashboardVC` subscribe this noti at `ViewWillAppear` only
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(performNotificationChildSessionStartedAfter1Sec), userInfo: nil, repeats: false)
        
        // take note of current time once Session is started
        updateLastSessionStopsAt()
        
        // increment child session count by 1
        UpdateChildSessionCount()
    }
    
    func StartUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            //self.showLocationAccessPopup()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            }
        } else {
            print("Location services are not enabled")
            self.showLocationAccessPopup()
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    // Update Active Child Session Count
    func UpdateChildSessionCount(){
        
        viewModel.updateChildSessionCount { (apiResponseHandler) in
            
            if apiResponseHandler.isSuccess() {
                
                if let response = Mapper<GetChildSessionResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                    
                    
                    //                let dict = response.jsonObject as! NSDictionary
                    //                let dictData = dict.value(forKey: "Data")
                    //                let CurrentSession = (dictData as AnyObject).value(forKey: "ChildSessionCount") as! Int
                    
                    //print(String(response.ChildSessionCount))
                    UserDefaults.standard.set(String(response.ChildSessionCount), forKey: "ChildSessionNumber")
                    UserDefaults.standard.synchronize()
                    
                    //Get Child's plano points
                    self.viewModel.getPlanoPoints()
                    
                }
            }
        }
    }
    
    // Update screen time when session has ended
    func UpdateScreenTime (){
        
        viewModel.updateScreenTime { (response) in
            
            if response.isSuccess(){
                _ = response.jsonObject as! NSDictionary
            }
            self.viewModel.getPlanoPoints()
        }
    }
    
    // Update session break extension timing
    func UpdateBreakSessionExtension (){
        
        viewModel.updateBreakSessionExtension { (response) in
            
            if response.isSuccess(){
                self.afterBreakExtension = false
                _ = response.jsonObject as! NSDictionary
            }
            self.viewModel.getPlanoPoints()
        }
    }
    
    @objc func performNotificationChildSessionStartedAfter1Sec(timer:Timer){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChildSessionManager.childSessionStartedIdentifier), object: nil, userInfo: nil)
    }
    
    
    // MARK: - For Logout with or without child session
    // We should not call this "scheduleLocalNotificationForResetAtEveryNight" to avoid "your device is ready to use" popup romdomly
    
    func destroyAllSessionsWithoutChildSession(){
        isSessionInit = false
        clearAllSessionsWithoutChildSession()
        clearAllLocationTracking()
        clearResetAtMidNightNotification()
    }
    
    func clearAllSessionsWithoutChildSession(){
        sessionEnded()
        stopChildTimer()
        
        deductedPointForRestTimeGoBackground = false
        
        updateLastSessionStopsAt()
        
        clearQueueAndNotificationTimers()
    }
    
    func clearQueueAndNotificationTimers(){
        
        // clear Background Queue
        stopGCDQueueTimer()
        
        // clear timer/notification
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    
    func switchToParentMode(){
        UserDefaults.standard.remove("LastScreenTimeAt")
        UserDefaults.standard.remove("SessionStartedAt")
        UserDefaults.standard.remove("TotalLockStateTime")
        UserDefaults.standard.remove("TotalScreenTime")
        UserDefaults.standard.remove("IsDeviceLocked")
        UserDefaults.standard.remove("IsDeviceUnlocked")
        
        destroyAllSessionsWithoutChildSession()
        
        //        if (UserDefaults.standard.integer(forKey: "IsTimerPaused") == 1) {
        //            UserDefaults.standard.set(Date(), forKey: "SessionStartedAt")
        //            UserDefaults.standard.synchronize()
        //
        //            sessionEndingTime = Date() + Constants.childSessionPeriod.seconds
        //
        //            sessionEndingBefore5Minute = sessionEndingTime - Constants.childSessionBeforeAfterGap.seconds
        //            sessionEndingAfter5Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGap.seconds
        //            sessionEndingAfter6Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGapPlus1.seconds
        //
        //            // local notification
        //            initLocalNotification()
        //
        //            //---------------------
        //            // start countdown to 35
        //            if let tm = timer {
        //                tm.invalidate()
        //            }
        //            isTimerUp(timer: nil) // need to manual start the `isTimerUp` not to lose 1|2 seconds
        //            // this line execute after 1 seconds because we give `timeInterval` to 1 -- meaning it will start calling `isTimerUp` after 1 seconds
        //            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(isTimerUp), userInfo: nil, repeats: true)
        //        }
    }
    
    // MARK: - Local session handling
    
    func sessionRestarted(){
        // stop & clear
        clearAllSessions()
        
        // start again
        sessionStarted()
    }
    
    func sessionEnded(){
        
        let childProfile = ActiveChildProfile.getProfileObj()
        
        if (childProfile?.lastSessionStopsAt != nil && UserDefaults.standard.object(forKey: "ChildSessionNumber") != nil) {
            UpdateScreenTime()
        }
        
        stopChildTimer()
        sessionActive = false
        breakTime = false
        
        UserDefaults.standard.remove("LastScreenTimeAt")
        UserDefaults.standard.remove("SessionStartedAt")
        UserDefaults.standard.remove("TotalLockStateTime")
        UserDefaults.standard.remove("TotalScreenTime")
        UserDefaults.standard.remove("IsDeviceLocked")
        UserDefaults.standard.remove("IsDeviceUnlocked")
    }
    
    func clearAllSessions(){
        sessionEnded()
        stopChildTimer()
        
        deductedPointForRestTimeGoBackground = false
        
        updateLastSessionStopsAt()
        
        clearQueueAndNotificationTimersAndResetEveryNightSchedule()
    }
    
    func clearQueueAndNotificationTimersAndResetEveryNightSchedule(){
        
        // clear Background Queue
        stopGCDQueueTimer()
        
        // clear timer/notification
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
        
        // after LocalNoti is cleared. Make sure to put back the mid-night reset
        scheduleLocalNotificationForResetAtEveryNight()
    }
    
    func destroyAllSessions(){
        isSessionInit = false
        clearAllSessions()
        clearAllLocationTracking()
        clearResetAtMidNightNotification()
    }
    
    func clearAllLocationTracking(){
        LocationBackgroundManager.sharedInstance.stopMonitoring()
    }
    
    @objc func sessionEndedWithPanelty(){
        log.debug(#function)
        sessionEnded()
        switchToRestModeOrComeBackTmr()
        
        // update score to server and local
        updateProgressScore(deduct: true, desc: childSessionPointStatus.text_stop_using_device_or_lose_250.rawValue)
        
        _ = registerLocalNoti(message: "250 points has been deducted.".localized(), fireDate: Date(), category: nil)
    }
    
    func switchToRestModeOrComeBackTmr(){
        if doesHaveRemainingSession() {
            switchToRestMode()
        }else{
            comeBackTomorrow()
        }
    }
    
    func switchToRestMode(){
        breakTime = true
        
        if Constants.isProduction { // production session
            
            // break time (90 second)
            breakTimeTimerDate = Date() + Constants.breakTimePeriod.seconds
            
        }else{ // this is for debug session
            
            // break time (90 second)
            breakTimeTimerDate = Date() + Constants.breakTimePeriodDebug.seconds
        }
        
        breakTimeAfter5Minute = breakTimeTimerDate! + breakTimeTimeInterval.seconds // break time after 5
        GCDTimerForBreakTime()
    }
    
    func getActiveChildProfile() -> ActiveChildProfile? {
        return ActiveChildProfile.getProfileObj()
    }
    
    func getActiveChildSessionNumber() -> Int {
        if let acp = getActiveChildProfile() {
            return acp.remainingChildSession
        }
        return 0
    }
    
    func updateLastSessionStopsAt(){
        if let acp = getActiveChildProfile() { // store in Realm
            acp.updateLastSessionStopsAt()
        }
    }
    
    func doesHaveRemainingSession() -> Bool {
        if let acp = getActiveChildProfile() {
            let have = acp.doesHaveRemainingSession()
            dailyUsageOver = !have
            return have
        }
        return false
    }
    
    func updateRemainingSessionCount(){
        if let acp = getActiveChildProfile() {
            acp.updateRemainingSessionCount()
        }
    }
    
    func resetRemainingSessionCount(){
        if let acp = getActiveChildProfile() {
            acp.resetRemainingSessionCount()
        }
    }
    
    func resetRemainingGamePlayCount(){
        if let acp = getActiveChildProfile() {
            acp.resetRemainingGamePlayCount()
        }
    }
    
    func resetUsingDeviceAtNightFlag(){
        if let acp = getActiveChildProfile() {
            acp.updateUsingDeviceAtNight(isNight: false)
        }
    }
    
    func resetSpeechBubble(){
        if let acp = getActiveChildProfile() {
            acp.updateDisplayedSpeechBubbleForToday(false)
        }
    }
    
    func resetDisplayedProgressScoreFlag(){
        if let acp = getActiveChildProfile() {
            acp.updateDisplayedProgressScoreToday(displayed: false)
        }
    }
    
    
    // MARK: - System/OS Events
    
    func appEnterForeground(){
        
        guard childSessionActive() else {
            return
        }
        
        resetChildSessionEachDayIfRequiredAndShowPopup()
        
        processShowPopupIfRequired()
        
        // start timer
        scheduleLocalNotificationForResetAtEveryNight()
        
        if CLLocationManager.locationServicesEnabled() {
            print("Start updating location service for background mode")
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func appEnterBackground()
    {
        let childProfile = ActiveChildProfile.getProfileObj()
        
        if (childProfile?.lastSessionStopsAt != nil && UserDefaults.standard.object(forKey: "ChildSessionNumber") != nil) {
            UpdateScreenTime()
        }
        
        guard childSessionActive() else {
            return
        }
        
        if sessionActive && shouldShowEyeCalibration() {
            showEyeCaliNoti()
        }else{
            ChildSessionManager.sharedInstance.deductPointForBreakTimeGoBackgroundIfRequired()
        }
        
        // clear ResetAtMidNight Noti
        clearResetAtMidNightNotification()
    }
    
    func appIsTerminated(){
        
        guard childSessionActive() else {
            return
        }
        
        self.updateChildPoint(point: Constants.pointDeductionForTerminatingApp)
        self.clearAllSessions()
        
        _ = registerLocalNoti(message: "You have closed the plano app, lose 500 points.".localized(), fireDate: Date()+1.seconds, category: nil)
        
    }
    
    // MARK: - Local Notification
    
    func childSessionActive() -> Bool {
        if let _ = getActiveChildProfile() {
            return true
        }else{
            return false
        }
    }
    
    func handleLocalNotification(_ identifier:String?){
        
        guard childSessionActive() else {
            return
        }
        
        if let idf = identifier {
            if idf == ChildSessionManager.eyeCalibrationNotiIdentifier {
                
                // clear existing timer to deduct -50 point
                clearEyeCalibrationGCDTimer()
                
                // send out PushNoti so `ChildDashboardVC` can take over to show the popup
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChildSessionManager.eyeCalibrationNotiIdentifier), object: nil, userInfo: nil)
            }else if idf == ChildSessionManager.usingDeviceAtNight {
                showUsingDeviceAtNightPopup()
            }else if idf == ChildSessionManager.resetChildSessionEachDayIdentifier {
                resetChildSessionEachDay()
                showPopupIfRequired()
            }else{
                showPopupIfRequired()
            }
        }else{
            showPopupIfRequired()
        }
    }
    
    
    
    // MARK: - Progress Score
    
    func resetProgressScore(){
        if let acp = getActiveChildProfile() {
            acp.resetProgressScore()
        }
    }
    
    func updateProgressScore(deduct:Bool, desc:String){
        
        var deductPoint = -1
        
        if !deduct{
            deductPoint = 1
        }
        
        if let acp = getActiveChildProfile(), let token = childAccessToken() {
            
            // call api
            let request = UpdateProgressRequest(ChildID: acp.childID, Access_Token: token, Description: desc, DeductPoint: deductPoint, ProgressDateTime: Date())
            ChildApiManager.sharedInstance.updateProgressDaily(request, completed: { (a, b) in
                //
            })
            
            // store locally
            acp.updateProgressScore(deductPoint, deduct)
            
        }
        
        
    }
    
    func comeBackTomorrow(){
        dailyUsageOver = true
        showPopupIfRequired()
    }
    
    // MARK: - Deduct Point for going background after Rest Time
    
    func deductPointForBreakTimeGoBackgroundIfRequired(){
        let currentStatus:childSessionStatus = checkChildSessionStatus()
        
        switch currentStatus {
        case .breakTime:
            deductedPointForRestTime()
        default: break
        }
        
    }
    
    func deductedPointForRestTime(){
        if !deductedPointForRestTimeGoBackground {
            
            // update score to server and local
            updateProgressScore(deduct: true, desc: childSessionPointStatus.text_user_leaves_rest_screen.rawValue)
            
            deductedPointForRestTimeGoBackground = true
            _ = registerLocalNoti(message: "250 points has been deducted for leaving plano.".localized(), fireDate: Date(), category: nil)
        }
    }
    
    
    // MARK: - Event from Popups
    
    func useDeviceNowWithoutAnyRewardOrPanelty(){ // use device without any rewards/panetly
        sessionRestarted()
    }
    
    func useDeviceNowAfterRestedMoreThan5Minute(){
        
        // process to get session number
        let sessionNumber = getActiveChildSessionNumber()
        var desc:childSessionPointStatus = .text_rest_more_than_5mins_session_1
        
        switch(sessionNumber){
        case 3: desc = .text_rest_more_than_5mins_session_1
        case 2: desc = .text_rest_more_than_5mins_session_2
        case 1: desc = .text_rest_more_than_5mins_session_3
        case 0: desc = .text_rest_more_than_5mins_session_4
        default: break
        }
        
        // restart session
        useDeviceNowWithoutAnyRewardOrPanelty()
    }
    
    func continueDeviceUsageFor50Points(){
        
        // process to get session number
        let sessionNumber = getActiveChildSessionNumber()
        var desc:childSessionPointStatus = .text_extend_5mins_after_35mins_session_1
        
        switch(sessionNumber){
        case 3: desc = .text_extend_5mins_after_35mins_session_1
        case 2: desc = .text_extend_5mins_after_35mins_session_2
        case 1: desc = .text_extend_5mins_after_35mins_session_3
        case 0: desc = .text_extend_5mins_after_35mins_session_4
        default: break
        }
        
        // update score to server and local
        updateProgressScore(deduct: true, desc: desc.rawValue)
        
        // clear GCD bg timer for for point deduction
        if let q = after1MinuteTimer {
            q.cancel()
        }
        after1MinuteTimer = nil
    }
    
    func stop5MinuteBefore35Minute(){
        
        // process to get session number
        let sessionNumber = getActiveChildSessionNumber()
        var desc:childSessionPointStatus = .text_stop_at_5_mins_pior_to_35mins_session_1
        
        switch(sessionNumber){
        case 3: desc = .text_stop_at_5_mins_pior_to_35mins_session_1
        case 2: desc = .text_stop_at_5_mins_pior_to_35mins_session_2
        case 1: desc = .text_stop_at_5_mins_pior_to_35mins_session_3
        case 0: desc = .text_stop_at_5_mins_pior_to_35mins_session_4
        default: break
        }
        
        stopDeviceUsageNow()
    }
    
    func stopDeviceUsageNow(){
        clearAllSessions()
        switchToRestModeOrComeBackTmr()
        showPopupIfRequired()
    }
    
    func continueDeviceUsageWithPermission(deductPoint:Int){
        if let acp = getActiveChildProfile() {
            acp.extendChildSession()
        }
        
        if dailyUsageOver {
            dailyUsageOver = false
        }
        
        if afterBreakExtension {
            afterBreakExtension = false
        }
        
        resetChildOutsideSafeArea()
        sessionRestarted()
    }
    
    func updateChildPoint(point:Int){
        
        if point < 1 {
            return /// don't bother to call api coz it's 0
        }
        
        if let childProfile = getActiveChildProfile(),
            let accessToken = childAccessToken() {
            
            let request = UpdateChildPointRequest(childID: childProfile.childID, accessToken: accessToken)
            
            // call api to update
            ChildApiManager.sharedInstance.updateChildPoint(request, completed: {[weak self] (apiResponseHandler, error) in
                if apiResponseHandler.isSuccess() {
                    if let response = Mapper<UpdateChildPointResponse>().map(JSONObject: apiResponseHandler.jsonObject) {
                        
                        // store point from server
                        if let cp = self?.getActiveChildProfile() {
                            cp.updateGamePoint(response.point)
                        }
                    }
                }
            })
        }
    }
    
    func updateToServerForEyeCalibration(didEyeChecked:Bool, eyeDistance:String){
        if let acp = getActiveChildProfile(), let token = acp.accessToken {
            let eyeCheck = didEyeChecked ? "1" : "0"
            let data = UpdateEyeCalibrationRequest(ChildID: acp.childID, Access_Token: token, EyeCheck: eyeCheck, EyeDistance: eyeDistance)
            ChildApiManager.sharedInstance.updateEyeCalibration(data) { (handler, error) in
                // do nothing
            }
        }
    }
    
    
    func updateToServerForBehaviourEyeCalibration(didEyeChecked:Bool){
        
        if let acp = getActiveChildProfile(), let token = acp.accessToken {
            
            let sessionNumber = UserDefaults.standard.string(forKey: "ChildSessionNumber")
            
            let eyeCheck = didEyeChecked ? "True" : "False"
            let data = UpdateBehaviourEyeCalibrationRequest(ChildID: acp.childID, Access_Token: token, SessionNumber: sessionNumber!, IsTested: eyeCheck)
            ChildApiManager.sharedInstance.updateBehaviourEyeCalibration(data) { (handler, error) in
                
                self.viewModel.getPlanoPoints()
            }
        }
    }
    
    
    func updateToServerForPosture(postureActive:Bool){
        if let acp = getActiveChildProfile(), let token = acp.accessToken, let parent = ProfileData.getProfileObj() {
            let active = postureActive ? "1" : "0"
            let data = UpdatePostureRequest(Email: parent.email, ChildID: acp.childID, Access_Token: parent.accessToken, PostureActive: active)
            ChildApiManager.sharedInstance.updatePostureCalibration(data) { (handler, error) in
                // do nothing
            }
        }
    }
    
    // MARK: Timer and Logics
    
    func childAccessToken() -> String? {
        return Defaults[.childAccessToken]
    }
    
    ////// Timer
    
    @objc fileprivate func isTimerUp(timer:Timer?){
        
        let currentTime = Date()
        
        var interval:TimeInterval = 0.0
        var interValInt = 0
        
        // stop the session Immediately after the timer ends
        // no need to give -250 per usage further more
        if dailyUsageOver {
            clearAllSessions()
            showPopupIfRequired()
            return
        }
        
        // check if break time
        if let btet = breakTimeTimerDate, breakTime {
            interval = btet.timeIntervalSince(currentTime)
            interValInt = max(0, Int(interval)) // to prevent from negative value
            log.debug(interValInt)
            if interValInt <= 0 {
                
                // show popup
                //                DispatchQueue.main.async {
                self.openModelViewController("PopupRestBonusVC")
                //                }
                
                // Start counting Upward
                GCDTimerForBreakTimeAfter90Sec()
            }
            
        }else{ // assume it's main session. will show "35:00 -> 00:00 -> -05:00"
            interval = sessionEndingTime.timeIntervalSince(currentTime)
            interValInt = Int(interval)
        }
        
        updateTimerView(interValInt)
        UserDefaults.standard.set(0, forKey: "IsTimerPaused")
    }
    
    @objc fileprivate func upwardTimer(){
        let currentTime = Date()
        
        var interval:TimeInterval = 0.0
        var interValInt = 0
        
        // check if break time
        if let btet = breakTimeTimerDate, breakTime {
            interval = currentTime.timeIntervalSince(btet)
            interValInt = Int(interval) // to prevent from negative value
            log.debug(interValInt)
        }
        
        // after 5 minutes, we show another popup
        let timeIntv = Constants.isProduction ? Constants.breakTimeAfter5Minute : Constants.breakTimeAfter5MinuteDebug
        
        if interValInt >= timeIntv { // TODO: change with 5*60
            showPopupIfRequired()
            stopGCDQueueTimer()
        }
        
        updateTimerView(interValInt)
    }
    
    fileprivate func updateTimerView(_ interValInt:Int){
        
        var finalString = ""
        
        if interValInt > 0 {
            let (m,s) = secondsToMinutesSeconds(seconds: interValInt)
            let secondString = s < 10 ? String(format: "%02d", s) : "\(s)"
            let minuteString = m < 10 ? String(format: "%02d", m) : "\(m)"
            finalString = "\(minuteString):\(secondString)"
        }else{
            var (m,s) = secondsToMinutesSeconds(seconds: interValInt)
            (m,s) = (abs(m),abs(s))
            let secondString = s < 10 ? String(format: "%02d", s) : "\(s)"
            let minuteString = m < 10 ? String(format: "%02d", m) : "\(m)"
            finalString = "-\(minuteString):\(secondString)"
        }
        
        log.debug(finalString)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChildSessionManager.timerNotificationIdentifier), object: finalString, userInfo: nil)
        
        
        //        if let quit = appQuiteLocalNotification {
        //            UIApplication.shared.cancelLocalNotification(quit)
        //        }
        //        appQuiteLocalNotification = registerLocalNoti(message: "Oh no! app has been quit.", fireDate: Date()+3.seconds, category: nil)
        //
        //        if let q = appQuiteTimer {
        //            q.cancel()
        //        }
        //        createGCDTimer(repeated: false, timer: &appQuiteTimer, interval: 3) {[weak self] (_) in
        //            self?.updateChildPoint(point: 55, deduct: true, desc: "")
        //        }
        
    }
    
    fileprivate func stopChildTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func stopGCDQueueTimer(){
        if let q = breakTimeTimer {
            q.cancel()
        }
        if let q = after6MinuteTimer {
            q.cancel()
        }
        if let q = after1MinuteTimer {
            q.cancel()
        }
        
        if let q = needEyeCalibration1MinuteTimer {
            q.cancel()
        }
        if let q = usingDeviceAtNightTimer {
            q.cancel()
        }
        
        after6MinuteTimer = nil
        after1MinuteTimer = nil
    }
    
    fileprivate func secondsToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // MARK: - Local Notification
    
    fileprivate func initLocalNotification(){
        
        if (UserDefaults.standard.integer(forKey: "IsAssignedNotification") == 1) {
            // clear timer/notification
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            } else {
                UIApplication.shared.cancelAllLocalNotifications()
            }
        }
        
        fiveMinuteBefore()
        sessionTimesUp()
        fiveMinuteAfter()
        
        GCDTimerForAfter1Minute()
        GCDTimerForAfter6Minute()
        UserDefaults.standard.set(1, forKey: "IsAssignedNotification")
    }
    
    fileprivate func fiveMinuteBefore(){
        
        // register local notification
        _ = registerLocalNoti(message: "Come back to plano to take a break from the device now for 100 bonus plano points.".localized(), fireDate: sessionEndingBefore5Minute, category: "fiveMinuteBefore")
    }
    
    fileprivate func sessionTimesUp(){
        
        // register local notification
        _ = registerLocalNoti(message: "Come back to plano to take a break from the device now for 50 bonus plano points.".localized(), fireDate: sessionEndingTime, category: "sessionTimesUp")
    }
    
    fileprivate func fiveMinuteAfter(){
        
        // register local notification
        _ = registerLocalNoti(message: "Come back to plano to take a break and rest your eyes now.".localized(), fireDate: sessionEndingAfter5Minute, category: "fiveMinuteAfter")
    }
    
    fileprivate func createUserNotiAction(identifier:String, title:String) -> UIMutableUserNotificationAction {
        let action = UIMutableUserNotificationAction()
        action.identifier = identifier
        action.title = title.localized()
        action.activationMode = UIUserNotificationActivationMode.background
        action.isAuthenticationRequired = false
        action.isDestructive = false
        return action
    }
    
    fileprivate func registerAction(categories:Set<UIMutableUserNotificationCategory>){
        let types:UIUserNotificationType = [.alert]
        let mySet:Set<UIMutableUserNotificationCategory> = categories
        let settings = UIUserNotificationSettings(types: types, categories: mySet)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    fileprivate func registerLocalNoti(message:String, fireDate:Date, category:String?) -> UILocalNotification {
        let notification = UILocalNotification()
        notification.alertBody = message.localized()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = fireDate
        if let cat = category {
            notification.category = cat
        }
        UIApplication.shared.scheduleLocalNotification(notification)
        return notification
    }
    
    fileprivate func sendLocalNoti(message:String){
        let notification = UILocalNotification()
        notification.alertBody = message.localized()
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    
    // MARK: - Background Jobs
    
    
    // To deduct 50 pts for "Use 50 points for 5 more minutes. [Stop][Continue using]"
    fileprivate func GCDTimerForAfter1Minute() -> Void {
        
        createGCDTimer(repeated:false, timer: &after1MinuteTimer, interval: after1MinuteTimerDispatchTimeIntervalSecond) { () in
            
        }
    }
    
    // To deduct 250 pts for "OK, time's really up. [Stop] [Use with permission]"
    fileprivate func GCDTimerForAfter6Minute() -> Void {
        
        createGCDTimer(repeated:false, timer: &after6MinuteTimer, interval: dispatchTimeIntervalSecond) { () in
            // I want to exclude deduction if session breaks are not followed, so sessionEndeddWithPanelty function calling stopped here.
        }
    }
    
    // To deduct -250 pts if app goes to background "Use device in 1:29. Keep this screen open until countdown ends or lose 250 points. [Use with permission]"
    fileprivate func GCDTimerForBreakTime() -> Void {
        
        createGCDTimer(repeated:true, timer: &breakTimeTimer, interval: 0) { () in
            self.isTimerUp(timer: nil)
        }
    }
    
    fileprivate func GCDTimerForBreakTimeAfter90Sec() -> Void {
        
        createGCDTimer(repeated:true, timer: &breakTimeTimer, interval: 0) { () in
            self.upwardTimer()
        }
    }
    
    // 1 minute after session ended. we need to deduct 50 pts.
    fileprivate func createGCDTimer(repeated:Bool, timer:inout DispatchSourceTimer?, interval:Int, callback: @escaping (() -> Void)){
        
        if (timer != nil) {
            timer!.cancel();
        }
        
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: backgroundQueue);
        
        if repeated {
            timer?.scheduleRepeating(deadline: .now(), interval: .seconds(1) ,leeway:.milliseconds(0));
        }else{
            let dpt = DispatchTime.now() + DispatchTimeInterval.seconds(interval)
            timer?.scheduleOneshot(deadline: dpt)
        }
        
        timer!.setEventHandler(handler: {[weak timer] () -> Void in
            if !repeated {
                timer!.cancel();
            }
            
            callback()
        });
        
        timer!.resume();
    }
    
    
    // MARK: - Session/Popup Logics
    
    func checkChildSessionStatus() -> childSessionStatus {
        
        var status:childSessionStatus = childSessionStatus.emptyStatus
        
        if sessionActive {
            
            let sessionTimeAfter6Minute = sessionEndingAfter6Minute
            let sessionTimeAfter = sessionEndingAfter5Minute
            let sessionTime = sessionEndingTime
            let sessionTimeBefore = sessionEndingBefore5Minute
            
            let currentTime = Date()
            if currentTime >= sessionTimeAfter6Minute {
                status = .sixMinuteAfter35
            }else if currentTime >= sessionTimeAfter {
                // over 35 minutes
                status = .fiveMinuteAfter35
            }else if currentTime >= sessionTime {
                // 35 minutes is up
                status = .timesUp
            }else if currentTime >= sessionTimeBefore {
                // 30 minutes
                status = .fiveMinuteBefore35
            }
            
        }else if(breakTime){
            
            status = .breakTime
            
            let currentTime = Date()
            
            if let bttd = breakTimeTimerDate, let bta5m = breakTimeAfter5Minute {
                if(currentTime > bttd && currentTime <= bta5m){
                    status = .breakTimeAfter90Sec
                }else if(currentTime > bta5m){
                    status = .breakTimeAfter5Min
                }
            }
            
        }else if(deviceCanNowBeUsed){ // No active session and no break time
            status = .deviceCanNowBeUsed
        }
        
        return status
    }
    
    fileprivate func showPopupIfRequired(){
        
        if !isChildInSafeZone() {
            showYouAreOutsideSafeAreaPopup()
            return
        }
        
        if dailyUsageOver {
            openModelViewController("PopupRedComeBackTmrVC")
            return
        }
        
        if afterBreakExtension {
            openModelViewController("PopoupRedStopUsingTheDevice")
            return
        }
        
        let currentStatus:childSessionStatus = checkChildSessionStatus()
        
        var vcName = ""
        
        switch currentStatus {
        case .deviceCanNowBeUsed:
            vcName = "PopupDeviceCanUseVC"
            openModelViewController(vcName)
            break
        case .fiveMinuteAfter35:
            afterBreakExtension = true
            vcName = "PopoupRedStopUsingTheDevice"
            openModelViewController(vcName)
            break
        case .timesUp:
            vcName = "PopupOrangeMoreMinutesVC"
            openModelViewController(vcName)
            break
        case .fiveMinuteBefore35:
            vcName = "PopupStopforBonusVC"
            openModelViewController(vcName)
            break;
        case .breakTimeAfter5Min:
            vcName = "PopupWellRestedEyeVC"
            openModelViewController(vcName)
        case .breakTimeAfter90Sec:
            vcName = "PopupRestBonusVC"
            openModelViewController(vcName)
        case .breakTime:
            // show random VC
            var randomArray = ["PopupOutdoorTodayVC","PopupSomePlaytimeVC","PopupLookFarVC","PopupRestEyesVC"]
            randomArray.shuffle()
            vcName = randomArray[0]
            openModelViewController(vcName)
        default: break
        }
    }
    
    func processShowPopupIfRequired(){
        // check if childSession
        guard isSessionInit else {
            return
        }
        
        showPopupIfRequired()
    }
    
    func openModelViewController(_ vcName:String){
        DispatchQueue.main.async { // calling this here via GCD will make sure UI won't crash
            self.openModelViewControllerInBackground(vcName)
        }
    }
    
    func openModelViewControllerInBackground(_ vcName:String){
        // display
        if vcName.isEmpty {
            return // do nothing
        }
        
        let vc = UIStoryboard.PopupVCByName(vcName)
        vc.modalPresentationStyle = .overFullScreen
        
        if let topVC = UIViewController.top {
            if topVC.className != vcName {
                
                // dismiss if [Ok, Time's up popup] -> [Asking Password] popup
                if topVC.isKind(of: SwitchToParentVC.self) {
                    topVC.dismiss(animated: true, completion: {
                        self.dismissExistingPopup(vc)
                    })
                }else{
                    // dismiss if [Ok, Time's up popup] popup
                    self.dismissExistingPopup(vc)
                    
                }
                
            } // don't show the popup if already there
        }
    }
    
    func dismissExistingPopup(_ vc:UIViewController){
        if let anotherTopVC = UIViewController.top {
            
            // dismiss if
            if anotherTopVC.isKind(of: _BasePopupViewController.self) {
                anotherTopVC.dismiss(animated: true, completion: {
                    
                    self.openViewController(vc)
                })
            }else{
                self.openViewController(vc)
            }
        }
    }
    
    func openViewController(_ vc:UIViewController){
        if let anotherTopVC = UIViewController.top {
            anotherTopVC.present(vc, animated: true, completion: nil)
        }
    }
    
    
    // MARK: -
    func speechBubblePopupDone(){
        
    }
    
    // MARK: - Eye Calibration
    func resetEyeCalibration(){
        if let acp = getActiveChildProfile() {
            acp.resetEyeCalibration()
        }
    }
    
    func updateEyeCalibrationCount(){
        if let acp = getActiveChildProfile() {
            acp.updateEyeCalibrationCount()
        }
    }
    
    func shouldShowEyeCalibration() -> Bool {
        if let acp = getActiveChildProfile() {
            let shouldShow = acp.shouldShowEyeCalibration() && sessionActive
            return shouldShow
        }
        return true
    }
    
    func showEyeCaliNoti(){
        _ = registerLocalNoti(message: "You haven't completed your eye distance check. Complete now or lose 50 points.".localized(), fireDate: Date(), category: ChildSessionManager.eyeCalibrationNotiIdentifier)
        
        // deduct -50 points after 1 minute without any activity
        
        if Constants.isProduction { // production session
            
            needEyeCalibration1MinuteDispatchTimeIntervalSecond = Constants.skipEyeCalibrationDeductionPointPeriod // seconds
            
        }else{ // this is for debug session
            
            needEyeCalibration1MinuteDispatchTimeIntervalSecond = Constants.skipEyeCalibrationDeductionPointPeriodDebug // seconds
            
        }
        
        createGCDTimer(repeated:false, timer: &needEyeCalibration1MinuteTimer, interval: needEyeCalibration1MinuteDispatchTimeIntervalSecond) {[weak self] () in
            if let me = self {
                // if still not calibrated, deduct 50 pts
                if me.shouldShowEyeCalibration() {
                    me.skipEyeCalibration()
                }
            }
        }
    }
    
    func skipEyeCalibration(){
        // update score to server and local
        updateProgressScore(deduct: true, desc: childSessionPointStatus.text_user_skip_eye_calibration.rawValue)
        
        // update to server for skipping
        updateToServerForEyeCalibration(didEyeChecked: false, eyeDistance: "")
    }
    
    func clearEyeCalibrationGCDTimer(){
        if let q = needEyeCalibration1MinuteTimer {
            q.cancel()
        }
        needEyeCalibration1MinuteTimer = nil
        log.debug(#function)
    }
    
    // MARK: - Using Device At Night
    
    /**
     * => 4.5.6.7.8.9.10.11.12.1.2.3.4.5.6.7.8 =>
     *     [ 1 ]{========================}
     *        [ 2 ]======================}
     *          {==[ 3 ]=================}
     *
     * 1. Before 7pm and won't overlap. Don't show popup
     * 2. Started before 7pm but overlap into it. Show popup at 7pm
     * 3. During night, show the Popup straigh away
     *
     **/
    func showUsingDeviceAtNightIfRequired(){
        
        if let acp = getActiveChildProfile() {
            
            if acp.usingDeviceAtNightToday == false {
                
                let status = checkUsingDeviceAtNightStatus()
                let msg = "Make sure you're using the device in a bright room.".localized()
                
                if status == .near7pm {
                    
                    if let date7pm = Date().atTime(hour: 19, minute: 0, second: 10) {
                        // make notification
                        _ = registerLocalNoti(message: msg, fireDate: date7pm, category: ChildSessionManager.usingDeviceAtNight)
                    }
                    
                }else if status == .duringNight {
                    
                    let date7pm = Date() + 1.seconds // show popup in 10 seconds
                    _ = registerLocalNoti(message: msg, fireDate: date7pm, category: ChildSessionManager.usingDeviceAtNight)
                    
                }
            }
        }
    }
    
    func checkUsingDeviceAtNightStatus() -> usingDeviceAtNightStatus {
        
        var totalDuration = Constants.childSessionPeriod + Constants.breakTimePeriod + Constants.breakTimeAfter5Minute // seconds
        
        if !Constants.isProduction {
            totalDuration = Constants.childSessionPeriodDebug + Constants.breakTimePeriodDebug + Constants.breakTimeAfter5MinuteDebug // seconds
        }
        
        /**
         * => 4.5.6.7.8.9.10.11.12.1.2.3.4.5.6.7.8 =>
         *     [ 1 ]{========================}
         *        [ 2 ]======================}
         *          {==[ 3 ]=================}
         *
         * 1. Before 7pm and won't overlap. Don't show popup
         * 2. Started before 7pm but overlap into it. Show popup at 7pm
         * 3. During night, show the Popup straigh away
         *
         **/
        
        let date = Date()
        let overlap = Date() + totalDuration.seconds
        
        if let after7pm = date.atTime(hour: 19, minute: 0, second: 0) {
            
            if isNight() {
                return .duringNight
            }else if overlap >= after7pm {
                return .near7pm
            }
        }
        
        return .notNight
    }
    
    private func isNight() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour >= 19 || hour < 5
    }
    
    func showUsingDeviceAtNightPopup(){
        if let acp = getActiveChildProfile() {
            acp.updateUsingDeviceAtNight(isNight: true)
        }
        // show popup
        let vc = UIStoryboard.PopupVCByName("PopupOrangeTooDarkVC")
        openViewController(vc)
    }
    
    // MARK: - Location Tracking
    
    func startLocationMonitoring(){
        if let acp = getActiveChildProfile() {
            LocationBackgroundManager.sharedInstance.stopMonitoring()
            LocationBackgroundManager.sharedInstance.locationManagerDelegate = self
            LocationBackgroundManager.sharedInstance.startMonitoring(Int(acp.childID))
        }
    }
    
    func isChildInSafeZone() -> Bool {
        if let acp = getActiveChildProfile() {
            return !acp.childIsOutsideSafeZone
        }
        return true
    }
    
    
    func didExitRegion(locationName:String){
        // call api to update
        if let acp = getActiveChildProfile(), let accessToken = childAccessToken() {
            let request = ChildLocationOutPushRequest(childID: acp.childID, accessToken: accessToken, locationName: locationName)
            ChildApiManager.sharedInstance.updateLocationOutPush(request, completed: { (a, b) in
                //
            })
        }
        
        childOutsideSafeArea()
    }
    
    func didEnterRegion(){
        
        // update in DB
        resetChildOutsideSafeArea()
        
        // start session
        // there is one exception. If we are outside safezone and click "use with permission" and session is active.
        // then we enter the safe region again. for this case, session is active and we don't wanna to stop and clear session
        // that's why I check whether `session` here is active or not. and only restart the whole session thing if not.
        if !sessionActive {
            startSessionIfRequired()
        }
        
        // dismiss PopupRedOutsideSafeAreaVC
        if let anotherTopVC = UIViewController.top {
            if anotherTopVC.isKind(of: PopupRedOutsideSafeAreaVC.self) {
                anotherTopVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func childOutsideSafeArea(){
        // stop and clear current sessions
        clearAllSessions()
        
        if let acp = getActiveChildProfile() {
            acp.childIsOutsideSafeZone(outside: true)
        }
        
        showYouAreOutsideSafeAreaPopup()
    }
    
    func showYouAreOutsideSafeAreaPopup(){
        
        openModelViewController("PopupRedOutsideSafeAreaVC")
        
    }
    
    func resetChildOutsideSafeArea(){
        if let acp = getActiveChildProfile() {
            acp.childIsOutsideSafeZone(outside: false)
        }
    }
    
    
    // MARK: - Reset Device at every night
    
    func scheduleLocalNotificationForResetAtEveryNight(){
        
        // clear before registring
        clearResetAtMidNightNotification()
        
        // init
        let title = "plano has reset".localized()
        let body = "the device is ready to use. Remember to follow the plano prompts.".localized()
        let categoryIdentifier = ChildSessionManager.resetChildSessionEachDayIdentifier
        
        // get current calendar
        let calendar = Calendar.current
        
        // create DateComponents from current calendar that will come with current TimeZone, Year, etc
        let unitFlags = Set<Calendar.Component>([.timeZone, .year, .month, .day, .hour, .minute, .second])
        var dateComponents = calendar.dateComponents(unitFlags, from: Date())
        
        // replace hour/minute/second only and keep other day/month/years to be same as today
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        let fireDate = calendar.date(from: dateComponents)
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = categoryIdentifier
            content.sound = UNNotificationSound.default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: categoryIdentifier, content: content, trigger: trigger)
            center.add(request)
            
        } else {
            
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = body
            notification.category = categoryIdentifier
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.fireDate = fireDate
            resetAtMidNightNotification = notification
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        log.debug(#function)
    }
    
    func clearResetAtMidNightNotification(){
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [ChildSessionManager.resetChildSessionEachDayIdentifier])
        }else{
            if let noti = resetAtMidNightNotification {
                UIApplication.shared.cancelLocalNotification(noti)
            }
            resetAtMidNightNotification = nil
        }
    }
    
    func ResumeTimer() {
        
        guard childSessionActive() else {
            return
        }
        
        let ScreenDuration = UserDefaults.standard.integer(forKey: "TotalScreenTime")
        let RemainingTime = Constants.childSessionPeriod - ScreenDuration
        sessionEndingTime = Date() + RemainingTime.seconds
        
        sessionEndingBefore5Minute = sessionEndingTime - Constants.childSessionBeforeAfterGap.seconds
        sessionEndingAfter5Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGap.seconds
        sessionEndingAfter6Minute  = sessionEndingTime + Constants.childSessionBeforeAfterGapPlus1.seconds
        
        //Again Register local notification
        initLocalNotification()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(isTimerUp), userInfo: nil, repeats: true)
        UserDefaults.standard.set(0, forKey: "IsTimerPaused")
    }
    
}


extension ChildSessionManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let str = "DidEnterRegion : \(region.identifier)"
        log.debug(str)
        
        // back in safe zone
        didEnterRegion()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let str = "You are outside the safe area.".localized()
        log.debug(str)
        
        // call api
        didExitRegion(locationName: region.identifier)
        
        // local notification
        _ = registerLocalNoti(message: str, fireDate: Date()+1.seconds, category: ChildSessionManager.youAreOutsideSafeArea)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //HUD.hide()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied: // authorizedAlways authorizedWhenInUse
            self.showLocationAccessPopup()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //HUD.hide()
        
        guard childSessionActive() else {
            return
        }
        
        let state = UIApplication.shared.applicationState
        if state == .inactive {
            print("App was inactive")
        }
        if state == .active {
            print("App is active")
        }
        if state == .background {
            print("App in Background")
        }
        
        let brightnessValue = UIScreen.main.brightness
        
        //        let date = Date()
        //        let calendar = Calendar.current
        
        //        let hour = calendar.component(.hour, from: date)
        //        let minutes = calendar.component(.minute, from: date)
        //        let seconds = calendar.component(.second, from: date)
        //        print("Last Hit time = \(hour):\(minutes):\(seconds)")
        
        
        if (brightnessValue == 0) {
            //print("brightness is 0 and device is locked");
            
            timer?.invalidate()
            let IsDeviceLocked = UserDefaults.standard.integer(forKey: "IsDeviceLocked")
            
            if (IsDeviceLocked == 1) {
                
                if (UserDefaults.standard.object(forKey: "LastScreenTimeAt") != nil) {
                    let ForegroundDate = UserDefaults.standard.object(forKey: "LastScreenTimeAt")
                    let ScreenDuration = UserDefaults.standard.double(forKey: "TotalLockStateTime")
                    
                    let TimeInterval = Date().timeIntervalSince(ForegroundDate! as! Date)
                    let IntervalDuration = round(TimeInterval)
                    let CurrentDuration = ScreenDuration + IntervalDuration
                    
                    print("TotalLockStateTime:\(ScreenDuration + IntervalDuration)")
                    UserDefaults.standard.set(CurrentDuration, forKey: "TotalLockStateTime")
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.set(0, forKey: "TotalLockStateTime")
                    UserDefaults.standard.synchronize()
                }
            } else {
                if (UserDefaults.standard.object(forKey: "LastScreenTimeAt") == nil && UserDefaults.standard.object(forKey: "SessionStartedAt") != nil) {
                    let ForegroundDate = UserDefaults.standard.object(forKey: "SessionStartedAt")
                    let ScreenDuration = UserDefaults.standard.double(forKey: "TotalLockStateTime")
                    
                    let TimeInterval = Date().timeIntervalSince(ForegroundDate! as! Date)
                    let IntervalDuration = round(TimeInterval)
                    let CurrentDuration = ScreenDuration + IntervalDuration
                    
                    print("TotalLockStateTime:\(ScreenDuration + IntervalDuration)")
                    UserDefaults.standard.set(CurrentDuration, forKey: "TotalLockStateTime")
                    UserDefaults.standard.synchronize()
                } else if (UserDefaults.standard.object(forKey: "LastScreenTimeAt") != nil) {
                    let ForegroundDate = UserDefaults.standard.object(forKey: "LastScreenTimeAt")
                    let ScreenDuration = UserDefaults.standard.double(forKey: "TotalScreenTime")
                    
                    let TimeInterval = Date().timeIntervalSince(ForegroundDate! as! Date)
                    let IntervalDuration = round(TimeInterval)
                    let CurrentDuration = ScreenDuration + IntervalDuration
                    
                    print("TotalScreenTime:\(ScreenDuration + IntervalDuration)")
                    UserDefaults.standard.set(CurrentDuration, forKey: "TotalScreenTime")
                    UserDefaults.standard.synchronize()
                }
            }
            
            // clear timer/notification
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            } else {
                UIApplication.shared.cancelAllLocalNotifications()
            }
            
            UserDefaults.standard.set(0, forKey: "IsAssignedNotification")
            UserDefaults.standard.set(1, forKey: "IsTimerPaused")
            UserDefaults.standard.set(1, forKey: "IsDeviceLocked")
            UserDefaults.standard.set(0, forKey: "IsDeviceUnlocked")
            UserDefaults.standard.synchronize()
            
        } else if (brightnessValue > 0) {
            //print("brightness is greater than 0 and device is not locked");
            
            
            let IsDeviceUnlocked = UserDefaults.standard.integer(forKey: "IsDeviceUnlocked")
            
            if (IsDeviceUnlocked == 1) {
                
                if (UserDefaults.standard.object(forKey: "LastScreenTimeAt") != nil) {
                    let ForegroundDate = UserDefaults.standard.object(forKey: "LastScreenTimeAt")
                    let ScreenDuration = UserDefaults.standard.double(forKey: "TotalScreenTime")
                    
                    let TimeInterval = Date().timeIntervalSince(ForegroundDate! as! Date)
                    let IntervalDuration = round(TimeInterval)
                    let CurrentDuration = ScreenDuration + IntervalDuration
                    
                    print("TotalScreenTime:\(ScreenDuration + IntervalDuration)")
                    UserDefaults.standard.set(CurrentDuration, forKey: "TotalScreenTime")
                    UserDefaults.standard.synchronize()
                } else {
                    UserDefaults.standard.set(0, forKey: "TotalScreenTime")
                    UserDefaults.standard.synchronize()
                }
            } else if (UserDefaults.standard.object(forKey: "LastScreenTimeAt") == nil && UserDefaults.standard.object(forKey: "SessionStartedAt") != nil) {
                let ForegroundDate = UserDefaults.standard.object(forKey: "SessionStartedAt")
                let ScreenDuration = UserDefaults.standard.double(forKey: "TotalScreenTime")
                
                let TimeInterval = Date().timeIntervalSince(ForegroundDate! as! Date)
                let IntervalDuration = round(TimeInterval)
                let CurrentDuration = ScreenDuration + IntervalDuration
                
                print("TotalScreenTime:\(ScreenDuration + IntervalDuration)")
                UserDefaults.standard.set(CurrentDuration, forKey: "TotalScreenTime")
                UserDefaults.standard.synchronize()
            }
            
            if (UserDefaults.standard.integer(forKey: "IsTimerPaused") == 1) {
                self.ResumeTimer()
            }
            
            UserDefaults.standard.set(1, forKey: "IsDeviceUnlocked")
            UserDefaults.standard.set(0, forKey: "IsDeviceLocked")
            UserDefaults.standard.synchronize()
        }
        
        UserDefaults.standard.set(Date(), forKey: "LastScreenTimeAt")
        UserDefaults.standard.synchronize()
        
        //        print("brightnessValue: \(brightnessValue)")
        //        if state == .background {
        //            print("App in Background")
        //
        //            if (brightnessValue == 0) {
        //                print("brightness is 0 and device is locked");
        //            } else if (brightnessValue > 0) {
        //                print("brightness is greater than 0 and device is not locked");
        //            }
        //
        //            //print(UIApplication.shared.backgroundTimeRemaining)
        //        }
        //        viewModel.getPlanoRecord { (response) in
        //
        //            if (response.jsonObject != nil){
        //                let dict = response.jsonObject as! NSDictionary
        //                let dictData = dict.value(forKey: "Data")
        //                let parentPoint = String((dictData as AnyObject).value(forKey: "ParentPlanoPoints") as! Int)
        //
        //                print("Plano points in background mode:\(parentPoint)")
        //                //self.lblParentPoints.text = parentPoint + " pts"
        //            }
        //        }
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            self.showLocationAccessPopup() // keep nagging to user to allow "always"
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //HUD.hide()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
        break // do nothing if authorized always
        default:
            self.showLocationAccessPopup() // keep nagging to user to allow "always"
            break
        }
    }
    
    func showLocationAccessPopup(){
        let alertController = UIAlertController(
            title: "Background Location Access Disabled".localized(),
            message: "In order to be notified about child device usage, please open this app's settings and set location access to 'Always'.".localized(),
            preferredStyle: .alert)
        //In order to be notified about adorable kittens near you, please open
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Enable".localized(), style: .default) { (action) in
            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
        alertController.addAction(openAction)
        
        //self.present(alertController, animated: true, completion: nil)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

