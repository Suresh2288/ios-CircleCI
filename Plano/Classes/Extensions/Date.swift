//
//  Date.swift
//  Plano
//
//  Created by Paing Pyi on 5/4/17.
//  Copyright © 2017 Codigo. All rights reserved.
//

import UIKit

extension Date {
    
    func toStringWith(format:String?) -> String {
        
        let dateFormatter = DateFormatter()
        
        if let fm = format {
            dateFormatter.dateFormat = fm
        }else{
            dateFormatter.dateFormat = "dd MMM yyyy"
        }
        let strDate = dateFormatter.string(from: self)
        
        return strDate
    }
    
    func getYesterday() -> Date{
        
        let calendar = Calendar.current
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())
        
        return yesterday!
    }
    
    func localToUTC(format:String) -> String {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = "h:mm a"
        dateFormator.calendar = NSCalendar.current
        dateFormator.timeZone = TimeZone.current
        
        dateFormator.timeZone = TimeZone(abbreviation: "UTC")
        dateFormator.dateFormat = format
        
        return dateFormator.string(from: self)
    }
    
    func add(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
}
