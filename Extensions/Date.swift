//
//  Date.swift
//  
//
//  Created by Dong on 2024/2/19.
//

import Foundation

extension Date {
    func getStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func getStartOfWeek() -> Date? {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        else { return nil }
        
        return calendar.date(byAdding: .day, value: 1, to: startOfWeek)
    }
    
    func getStartOfMonth() -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))
    }
    
    func getEndOfMonth() -> Date? {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month? += 1
        components.day? = 1
        components.day? -= 1
        
        return calendar.date(from: components)
    }
    
    func getMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: self)
    }
    
    func getYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
}
