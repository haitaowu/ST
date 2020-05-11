//
//  Employee.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct Employee:SimpleCodable {
    var employeeCode:String = ""
    var deptName:String = ""
    var employeeName:String = ""
    var ownerSite:String = ""
    var barPassword:String = ""
    var modifyDate:String = ""
    var deleteFlag:Int = 0
}

struct EmployeeLoadRequest:STRequest {
    var logicUrl: String{
        return "m8/initEmp.do"
    }
}
