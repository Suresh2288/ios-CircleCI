//
//  DefaultsKeys.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    
    static let pushToken = DefaultsKey<String>("pushToken")
    static let languageID = DefaultsKey<String>("languageID")

    static let displayedOnBoard = DefaultsKey<Bool>("displayedOnBoard")
    static let displayedGetStarted = DefaultsKey<Bool>("displayedGetStarted")
    
    static let displayedSwitchChildGuide = DefaultsKey<Bool>("displayedSwitchChildGuide")
    static let displayedTurnoffChildModeGuide = DefaultsKey<Bool>("displayedTurnoffChildModeGuide")
    
    static let lastFeedbackShownAt = DefaultsKey<Date?>("lastFeedbackShownAt")
    static let stopDisplayFeedback = DefaultsKey<Bool>("stopDisplayFeedback")

    static let childAccessToken = DefaultsKey<String?>("childAccessToken")
    
    static let lastAdsShownAt = DefaultsKey<Date?>("lastAdsShownAt")
    
    static let tempEmailOfNewUser = DefaultsKey<String?>("tempEmailOfNewUser")
    static let tempPWOfNewUser = DefaultsKey<String?>("tempPWOfNewUser")
    static let displayedSpeechBubbleList = DefaultsKey<[String]?>("displayedSpeechBubbleList")
    
    // child session

    static let remainingChildSession = DefaultsKey<Int>("remainingChildSession")
    static let remainingEyeCalibration = DefaultsKey<Int>("remainingEyeCalibration")
    static let lastSessionStopsAt = DefaultsKey<Date?>("lastSessionStartedAt")
    static let eyeGameWonToday = DefaultsKey<Bool>("eyeGameWonToday")
    static let matchGameWonToday = DefaultsKey<Bool>("matchGameWonToday")
    
    static let recentlyAddedChildID = DefaultsKey<Int?>("recentlyAddedChildID")
    static let recentlyAddedChildTimestamp = DefaultsKey<Date?>("recentlyAddedChildTimestamp")
    
    // subscription verification
    static let verifyTimeCheck = DefaultsKey<Date?>("verifyTimeCheck")
    static let currentPremiumID = DefaultsKey<String?>("currentPremiumID")
    
    // app flyer trackikng
    static let appFlyerId = DefaultsKey<String?>("appFlyerId")
    static let ipAddress = DefaultsKey<String?>("ipAddress")
}
