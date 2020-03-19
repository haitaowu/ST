//
//  NSDate+st.swift
//  ST
//
//  Created by yunchou on 2016/11/23.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

extension Date{
    static var stNow:String{
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f.string(from: Date())
    }
}
