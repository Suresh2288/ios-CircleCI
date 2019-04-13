//
//  WoopraTrackingPage.swift
//  Plano
//
//  Created by John Raja on 11/07/18.
//  Copyright © 2018 Codigo. All rights reserved.
//

import UIKit
import Woopra_iOS

class WoopraTrackingPage {
    
    func profileInfo(name: String,email: String,country: String, city: String,countryCode: String, mobile: String, profileImage: String,deviceType: String,deviceID: String){
        WTracker.shared.domain = "plano.co"
        WTracker.shared.visitor.add(properties: ["name":name,"email":email,"country code":country,"city":city,"countryCode":countryCode,"mobile":mobile,"profileImage":profileImage,"deviceType":deviceType,"deviceID":deviceID,"model":"iPhone","apiversion_code":"iPhone","apiversion_name":"iPhone","manufacturer":"Apple","app_version":"-" ])
    }
    
    func childProfileInfo(name: String,country: String,profileImage: String,deviceType: String,deviceID: String,childID:String,childGender:String,gamePoint:String){
        WTracker.shared.domain = "plano.co"
        WTracker.shared.visitor.add(properties: ["childfirstname":name,"country code":country,"profileImage":profileImage,"deviceType":deviceType,"model":"iPhone","childGender":childGender,"apiversion_code":"iPhone","apiversion_name":"iPhone","manufacturer":"Apple","childid":childID,"gamepoints":gamePoint,"app_version":"-"])
    }
    
    func trackEvent(mainMode:String,pageName:String,actionTitle:String){
        let event = WEvent.event(name: mainMode)
        event.add(property: "View", value: pageName)
        event.add(property: "Title", value: actionTitle)
        event.add(property: "User Type", value: "iOS")
        WTracker.shared.trackEvent(event)
    }
    
    
}
