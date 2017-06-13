//
//  DateUtil.swift
//  Basket
//
//  Created by Mario Radonic on 4/9/16.
//  Copyright © 2016 Basket Team. All rights reserved.
//

import Foundation
import SwiftDate

class DateUtil {

    fileprivate static let defaultFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter
    }()

    class func dateFromString(_ str: String) -> Date? {
        return defaultFormatter.date(from: str)
    }

    class func timeIntervalFromStringOrNonValue(_ str: String) -> TimeInterval? {
        guard !str.isEmpty else {
            return 0
        }

        var interval:Double = 0

        let parts = str.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        return interval
    }

    class func dateFromTimeInterval(_ interval: TimeInterval) -> Date {
        return NSDate(timeIntervalSinceReferenceDate: interval) as Date
    }
}

extension Date {

    var naturalReferenceString: String? {
        fatalError("Not yet implemented")
//        let style = FormatterStyle(
//            style: .Full,
//            units: [NSCalendar.Unit.Month, NSCalendar.Unit.Day, NSCalendar.Unit.Hour],
//            max: 2
//        )
//
//        let now = Date()
//        if let d = toNaturalString(now, style: style) {
//            let passed = self < now
//            if passed {
//                return "\(d) ago"
//            } else {
//                return "In \(d)"
//            }
//        } else {
//            return nil
//        }
    }

    var dateString: String? {
        let format = DateFormat.custom("MMM dd, yyyy")
        return self.string(format: format)
    }
}
