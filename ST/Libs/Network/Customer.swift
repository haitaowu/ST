//
//  Customer.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct Customer:SimpleCodable{
    var customerCode:String = ""
    var customerName:String = ""
}

class CustomerLoadRequest:STRequest{
    var logicUrl: String{
        return "/initCust.do"
    }
}
