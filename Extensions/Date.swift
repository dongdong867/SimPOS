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
}
