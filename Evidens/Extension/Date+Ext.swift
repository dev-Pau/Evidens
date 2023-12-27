//
//  Date+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/6/23.
//

import Foundation

/// An extension of date.
extension Date {
    
    /// Converts the date to a UTC timestamp.
    /// - Returns: The UTC timestamp as an integer.
    func toUTCTimestamp() -> Int {
        var calendar = Calendar.current
        let utcTimeZone = TimeZone(identifier: "UTC")
        calendar.timeZone = utcTimeZone!
        
        let utcDate = calendar.date(bySettingHour: calendar.component(.hour, from: self),
                                    minute: calendar.component(.minute, from: self),
                                    second: calendar.component(.second, from: self),
                                    of: self)
        
        return Int(utcDate!.timeIntervalSince1970)
    }
    
    /// Converts the date to a UTC date.
    /// - Returns: The UTC date.
    func toUTCDate() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let utcDate = calendar.date(bySettingHour: calendar.component(.hour, from: self),
                                    minute: calendar.component(.minute, from: self),
                                    second: calendar.component(.second, from: self),
                                    of: self)
        
        return utcDate ?? self
    }
}
