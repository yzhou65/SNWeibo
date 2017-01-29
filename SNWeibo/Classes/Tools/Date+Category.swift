//
//  Date+Category.swift
//  SNWeibo
//
//  Created by Yue Zhou on 1/26/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

extension Date {
    
    static func date(with time: String) -> Date {
        // convert the time string received from the server to Date
        let formatter = DateFormatter()
        
        // format the time and set time zone
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z yyyy"
        formatter.locale = Locale(identifier: "en")
        
        let createdDate = formatter.date(from: time)!
        return createdDate
    }
    
    /**
     Just now (within one minute)
     x minutes ago (within one hour)
     x hours ago (within one day)
     yesterday HH:mm (yesterday time)
     MM-dd HH:mm (within one year)
     yyyy-MM-dd HH:mm (earlier)
     */
    var descDate: String {
        let calendar = Calendar.current
        
        // convert the time string received from the server to Date
        let formatter = DateFormatter()
        
        // whether it is today
        if calendar.isDateInToday(self) {
            // the different between caller time and current system time
            let since = Int(Date().timeIntervalSince(self))
//            print("since = \(since)")
            
            // whether it is just now
            if since < 60 {
                return "Just now"
            }
            
            // whether it is within an hour
            if since < 60 * 60 {
                return "\(since/60) minutes ago"
            }
            
            // whether it is within one day
            return "\(since / (60 * 60)) hours ago"
        }
        
        // whether it is yesterday
        var formatStr = "HH:mm"
        if calendar.isDateInYesterday(self) {
            formatter.dateFormat = formatStr
            formatter.locale = Locale(identifier: "en_US")
            
            return "Yesterday " + formatter.string(from: self)
        }
        else { // not yesterday
            // within one year
            formatStr = "MM-dd " + formatStr
            
            // earlier
            let comps = calendar.dateComponents(Set<Calendar.Component>([.day, .month, .year]), from: self, to: Date())
            if comps.year! >= 1 {
                formatStr = "yyyy-" + formatStr
            }
        }
        
        
        // format the time and set time zone
        formatter.dateFormat = formatStr
        formatter.locale = Locale(identifier: "en_US")

        return formatter.string(from: self)
    }
}
