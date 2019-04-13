//
//  ReachabilityUtil.swift
//  Plano
//
//  Created by Thiha Aung on 8/31/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityUtil{
    
    static let shareInstance = ReachabilityUtil()
    
    func isOnline() -> Bool{
        let reachability = Reachability()!
        if reachability.isReachable{
            if reachability.isReachableViaWiFi || reachability.isReachableViaWWAN{
                log.info("You are connected to Internet!!!")
                return true
            }else{
                log.info("You are not connected to Internet!!!")
                if let window = UIApplication.shared.keyWindow{
                    window.rootViewController?.showAlert("No internet connection")
                }
                return false
            }
        }else{
            log.warning("Reachability Not Initiated!!!")
            if let window = UIApplication.shared.keyWindow{
                window.rootViewController?.showAlert("No internet connection")
            }
            return false
        }
    }
    
    func isOnlineWithNativePopup() -> Bool{
        let reachability = Reachability()!
        if reachability.isReachable{
            if reachability.isReachableViaWiFi || reachability.isReachableViaWWAN{
                log.info("You are connected to Internet!!!")
                return true
            }else{
                log.info("You are not connected to Internet!!!")
                return false
            }
        }else{
            log.warning("Reachability Not Initiated!!!")
            return false
        }
    }
}
