//
//  VerifyTimer.swift
//  Plano
//
//  Created by Thiha Aung on 8/7/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

class VerifyTimer: NSObject {
    
    var counter: Int = 0
    var timer: Timer! = Timer()
    
    var timerEndedCallback: (() -> Void)!
    var timerInProgressCallback: ((_ elapsedTime: Int) -> Void)!
    
    func startTimer(duration: Int, timerEnded: @escaping () -> Void, timerInProgress: ((_ elapsedTime: Int) -> Void)!) {
        
        if !(self.timer?.isValid != nil) {
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(timer:)), userInfo: duration, repeats: true)
            
            timerEndedCallback = timerEnded
            timerInProgressCallback = timerInProgress
            counter = 0
        }
    }
    
    @objc func updateTime(timer: Timer) {
        
        self.counter += 1
        let duration = timer.userInfo as! Int
        
        if (self.counter != duration) {
            timerInProgressCallback(self.counter)
        } else {
            timer.invalidate()
            timerEndedCallback()
        }
    }
}
