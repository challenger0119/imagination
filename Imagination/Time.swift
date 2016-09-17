//
//  Time.swift
//  Imagination
//
//  Created by Star on 15/12/1.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class Time: NSObject {
    static func now()->String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.string(from: Date.init(timeIntervalSinceNow: 0))
    }
    static func today()->String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: Date.init(timeIntervalSinceNow: 0))
    }
    static func clock()->String{
        let format = DateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.string(from: Date.init(timeIntervalSinceNow: 0))
    }
    static func dateFromString(_ time:String) -> Date? {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.date(from: time)
    }
    static func dayOfDate(_ date:Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
    static func clockOfDate(_ date:Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.string(from: date)
    }
}
