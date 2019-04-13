//
//  String.swift
//  Plano
//
//  Created by Paing Pyi on 20/2/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import Foundation

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func toIntFlag() -> Int? {
        switch self {
        case "True", "true", "yes", "1":
            return 1
        case "False", "false", "no", "0":
            return 0
        default:
            return nil
        }
    }
    
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    // Helpers
    // Convert from 14:00(YGN) to 7:30(UTC)
    func convertToUTCTimestamp() -> String? {
        let strArr:[String] = self.components(separatedBy: ":")
        guard strArr.count > 1 else {
            return nil
        }

        let int0 = Int(strArr[0])
        let int1 = Int(strArr[1])
        let calendar = Calendar.current
        let today = Date()
        
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: today)
        
        var newcom = DateComponents()
        newcom.year = com.year
        newcom.month = com.month
        newcom.day = com.day
        newcom.hour = int0
        newcom.minute = int1
        let newcomdate = calendar.date(from: newcom)!
        
        let finalf = DateFormatter()
        finalf.dateFormat = "HH:mm"
        finalf.timeZone = TimeZone(abbreviation: "UTC")
        let finalfString = finalf.string(from:newcomdate)
        return finalfString
    }
    
    // Convert from 7:30(UTC) to 14:00(YGN)
    func convertFromUTCTimestamp() -> String? {
        let strArr:[String] = self.components(separatedBy: ":")
        guard strArr.count > 1 else {
            return nil
        }
        
        let int0 = Int(strArr[0])
        let int1 = Int(strArr[1])
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        let today = Date()
        var com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: today)
        
        var newcom = DateComponents()
        newcom.year = com.year
        newcom.month = com.month
        newcom.day = com.day
        newcom.hour = int0
        newcom.minute = int1
        let newcomdate = calendar.date(from: newcom)!
        
        let finalf = DateFormatter()
        finalf.dateFormat = "HH:mm"
        return finalf.string(from:newcomdate)
    }
}
