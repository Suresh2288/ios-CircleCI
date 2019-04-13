//
//  AppFlyerHelper.swift
//  Plano
//
//  Created by Thiha Aung on 8/23/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import AppsFlyerLib

class AppFlyerHelper{
    
    func trackScreen (screenName: String){
        AppsFlyerTracker.shared().trackEvent(screenName, withValues: nil)
    }
}
