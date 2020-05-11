//
//  User.swift
//  ST
//
//  Created by yunchou on 2016/11/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//


import Foundation

struct User:SimpleCodable {
    var siteCode:String = ""
	///员工编号
    var empCode:String = ""
    var barPassword:String = ""
    var empName:String = ""
	///网点名称
    var siteName:String = ""
    var deptName:String = ""
    var phone:String = ""
    var address:String = ""
    var createDate:String = ""
    var confirmMoney:String = ""
	///纬度
    var latitude:String = ""
	///经度;
    var longitude:String = ""
	//司机账号
    var truckModels:String = ""
    var truckNum:String = ""
    var truckOwer:String = ""
    
    init() {
        
    }
    
    init(siteCode:String,empCode:String,barPassword:String) {
        self.siteCode = siteCode
        self.empCode = empCode
        self.barPassword = barPassword
    }
	
	///double 类型的经度
	func longi() -> Double {
		if(self.longitude.isEmpty){
			return 0
		}else{
			return Double(self.longitude)!
		}
	}
	
	
	///double 类型的纬度
	func lati() -> Double {
		if(self.latitude.isEmpty){
			return 0
		}else{
			return Double(self.latitude)!
		}
	}
	
}

struct UserLogin:STRequest {
    var user:User
    var logicUrl:String{
        return "/login.do"
    }
    var parameters: [AnyHashable : Any]{
        return [
            "siteCode":user.siteCode,
            "empCode":user.empCode,
            "barPassword":user.barPassword.stPasswrod()
        ]
    }
}

///中心用户
struct CenterModel:SimpleCodable {
    var siteName:String = ""
    var employeeCode:String = ""
    var passWord :String = ""

    init() {}
    
    init(siteName: String, acc:String, pwd: String){
        self.siteName = siteName
        self.passWord  = pwd
        self.employeeCode  = acc
    }
}

//中心用户登录
struct CenterLoginReq:STRequest {
    var user:CenterModel
    var logicUrl:String{
        return "Emp/loginEmp.do"
    }
    var parameters: [AnyHashable : Any]{
//        if let jsonDataStr = JSONSerializer.serialize(model: user) as? String{
		if let jsonDataStr = user.toJSONString(prettyPrint: true){
			let mdSignStr = jsonDataStr.employeeMdStr()
			let base64string = jsonDataStr.base64Str()
			return [
				"data":base64string,
				"sign":mdSignStr
			]
		}else{
			return [:]
		}
    }
}

///司机用户
struct DriverModel:SimpleCodable {
	//车牌号
	var carCode:String = ""
	var passWord:String = ""
	var phone:String = ""
	//司机账号
	var truckModels:String = ""
	var truckNum:String = ""
	var truckOwer:String = ""
	
	init() {}
	
	init(carCode: String, passWord: String){
		self.carCode = carCode
		self.passWord = passWord
    }
}


//司机用户登录Req
struct DriverLoginReq:STRequest {
    var user:DriverModel
    var logicUrl:String{

        return "Dri/loginDriver.do"
    }
    
    var parameters: [AnyHashable : Any]{
//        if let jsonDataStr = JSONSerializer.serialize(model: user) as? String{
        if let jsonDataStr = user.toJSONString(){
            let mdSignStr = jsonDataStr.driverMd5Str()
			let base64string = jsonDataStr.base64Str()
            print("DataJson:"+"\(jsonDataStr)"+"\n"+"Sign:"+"\(mdSignStr)")
            return [
                "data":base64string,
                "sign":mdSignStr
            ]
        }else{
            return [:]
        }
    }
}



