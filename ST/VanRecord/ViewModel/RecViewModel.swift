//
//  DriverModel.swift
//  ST
//
//  Created by taotao on 2019/9/19.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation




//中心网点到车/发车记录列表request
struct EmpSARecReq:STRequest {
	var params:[String:String]
	var logicUrl: String{
		return "Emp/findSendComeTruck.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = params.empMD5DataStr()
		return [
			"data":base64str,
			"sign":signStr
		]
	}
}

//MARK:- 司机到车、发车记录模型、Request
//司机、中心网点的到车、发车记录列表模型
struct SARecModel:SimpleCodable {
	//(String) 当前状态
	var endScanType: String = ""
	// (String) 路由
	var lineName: String = ""
	// (String) 清单编号
	var listCode: String = ""
	//  (String) 车牌号
	var truckNum: String = ""
	// (String) 类型
	var truckType: String = ""
}


//司机到车/发车记录列表request
struct DriSARecReq:STRequest {
	var params:[String:String]
	var logicUrl: String{
		return "Dri/findSendComeTruck.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = params.driverMD5DataStr()
		return [
			"data":base64str,
			"sign":signStr
		]
	}
}

//司机、发/到车记录中的发车数据
struct SendDataModel:SimpleCodable {
	//(String)是否外调加班车 0 否 1是
	var blTempWork: String = ""
	// (String)  路由名称
	var lineName: String = ""
	// (String)装载情况
	var picUrl: String = ""
	//(String) 到车时间
	var scanDate: String = ""
	// (String)操作人
	var scanMan: String = ""
	// (String)挂车号
	var truckCarNum: String = ""
	// (String)车牌号
	var truckNum: String = ""
	// (String)车型
	var truckType: String = ""
	
	///是否加班：1:加班     0或空:为不加班
	func blTempWorkStr() -> String {
		if(self.blTempWork == "1"){
			return "是"
		}else{
			return "否"
		}
	}
}


//司机、发/到车记录中的到车数据
struct ComeDataModel:SimpleCodable {
	//(String) 到车时间
	var scanDate: String = ""
	// (String)操作人
	var scanMan: String = ""
	// (String)到车中心
	var scanSite: String = ""
}

//司机、发/到车记录中的操作记录
struct OptDataModel:SimpleCodable {
	//(String)
	var blCheck: String = ""
	// (String)  下站点
	var nextSite: String = ""
	// (String)操作类型
	var operteType: String = ""
	//(String) 时间
	var scanDate: String = ""
	// (String)操作人
	var scanMan: String = ""
	// (String)
	var sendsealScanAhead: String = ""
	// (String)
	var sendsealScanBackDoor: String = ""
	// (String)
	var sendsealScanMittertor: String = ""
}


//司机、发/到车记录详情模型
struct DriSADetailModel:SimpleCodable {
	init() {
	}
	//到车数据
	var comeData: ComeDataModel = ComeDataModel()
	//发车数据
	var sendData: SendDataModel = SendDataModel()
	//操作数据
	var listInfo: Array<OptDataModel> = []
	//清单号
	var listCode: String = ""
	//
	var truckState: String = ""
	
}



//中心、司机到车/发车记录详情的request
struct DriSARecDetailReq:STRequest {
	var listCode:String
	let manager = DataManager.shared
	var logicUrl: String{
		if (manager.roleType == .driver) {
			return "Dri/findSendComeTruckCount.do"
		}else{
			return "Emp/findSendComeTruckCount.do"
		}
	}
	
	var parameters: [AnyHashable : Any]{
		let base64str = listCode.base64Str()
		var signStr = ""
		if (manager.roleType == .driver) {
			signStr = listCode.driverMd5Str()
		}else{
			signStr = listCode.employeeMdStr()
		}
		return [
			"data":base64str,
			"sign":signStr
			
		]
	}
}



