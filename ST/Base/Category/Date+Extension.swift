//
//  Date+Extension.swift
//  ST
//
//  Created by taotao on 2019/7/11.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

extension Date{
    
    func dateStringFrom(dateFormat:String="yyyy-MM-dd") -> String {
//        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.string(from: self)
        return dateStr
//        return date.components(separatedBy: " ").first!
    }

	
}
