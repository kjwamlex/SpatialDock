//
//  TimeManagement.swift
//  VisionDock
//
//  Created by Joonwoo KIM on 2023-06-29.
//

import Foundation

class TimeManagement: NSObject {
    
    func getDate() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = String(describing: calendar.component(.day, from: date))
        //let year = String(describing: calendar.component(.year, from: date))
        let dateFormatted = date.getFormattedDate(format: "EEE MMM")
        return dateFormatted + " " + day
    }
    
    func getAMorPM() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        let hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        
        return hoursSinceStartOfDay >= 12 ? "PM" : "AM"
    }
    
    func getHour(twelveHourTime: Bool) -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        var hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        
        if !twelveHourTime {
            if hoursSinceStartOfDay > 12 {
                hoursSinceStartOfDay -= 12
            }
        }
        
        return String(Int(hoursSinceStartOfDay))
    }
    
    func getMinute() -> String {
        let startOfDay = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        let hoursSinceStartOfDay = floor((currentTime - startOfDay) / 3600)
        let minuteSinceHour = ((currentTime - startOfDay - (hoursSinceStartOfDay * 3600)) / 60)
        if minuteSinceHour < 10 {
            return "0" + String(Int(minuteSinceHour))
        }
        
        
        return String(Int(minuteSinceHour))
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
