//
//  Date+Extension.swift
//  ST
//
//  Created by taotao on 2019/7/11.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

extension Date{
    
	///转换日期为指定格式的字符串
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
	

	///转换日期为指定格式的日期对象
	func dateFrom(format: String = "yyyy-MM-dd HH:mm:ss")-> Date{
		let dateStr = self.dateStringFrom(dateFormat: format)
		let date = dateStr.dateOf(format: format)
		return date
	}
	
	
	///当前日期是否为date日期之前的日期
	func isBefore(date: Date)-> Bool{
		let interval = self.timeIntervalSince(date)
		if interval < 0{
			return true
		}else{
			return false
		}
	}
	
}
