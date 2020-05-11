//
//  TransferType.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct TransferType:SimpleCodable{
    var classCode:String = ""
    var className:String = ""
    var modifyDate:String = ""
    var deleteFlag:Int = 0
}

struct TransferTypeLoadRequest:STRequest {
    var logicUrl: String{
			return "m8/initClass.do"
    }
}
