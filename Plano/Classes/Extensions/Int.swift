//
//  Int.swift
//  Plano
//
//  Created by Thiha Aung on 5/30/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation

extension Int {

    func toBool() -> Bool {
        switch self {
        case 1:
            return true
        case 0:
            return false
        default:
            return false
        }
    }
    
    func secondsToMinutesSeconds () -> (Int, Int) {
        return ((self % 3600) / 60, (self % 3600) % 60)
    }
}
