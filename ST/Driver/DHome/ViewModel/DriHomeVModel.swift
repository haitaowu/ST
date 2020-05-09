//
//  DriHomeVModel.swift
//  ST
//
//  Created by taotao on 2019/10/22.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation

	
	
//MARK:-司机首页公告
///司机首页公告模型
//struct DriMsgModel ext AnnoModel {
//	var content: String = ""
//	var noticeTime: String = ""
//	var person: String = ""
//	var title: String = ""
//	var sendSite: String = ""
//	init() {
//	}
//}

//司机首页公告req
struct DriMsgReq:STRequest {
	var carCode:String
	
	var logicUrl: String{
		return "Dri/qryHomeNoticeInfo.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let signStr = carCode.driverMd5Str()
		let base64str = carCode.base64Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}

//MARK:- 司机首页正在进行的发车

//司机首页正在进行的发车模型
struct UnFinishedModel:SimpleCodable {
	///发车流水号
	var sendCode: String = ""
	
	///是否加班：1 为 加班 0 或空 为不加班
	var blTempWork: String = ""
	//计划时间	：预计时间
	var arriveTime: String = ""
	///车牌号
	var truckNum: String = ""
	///车型
	var truckType: String = ""
	///挂车号
	var truckCarNum: String = ""
	///路由
	var lineName: String = ""
	///管理员:操作人
	var scanMan: String = ""
	///扫描时间：发车时间
	var scanDate: String = ""
	///封签号（后）
	var sendsealScanAhead: String = ""
	///封签号（前侧）
	var sendsealScanMittertor: String = ""
	///封签号（后侧
	var sendsealScanBackDoor: String = ""
	
	///修改后的下一站
	var bakNextStaTion: String = ""
	
	///司机发车状态 0 :未发车, 1:已发车
	var  deiverStatus: String = ""
	
	///是否加班：1:加班     0或空:为不加班
	func blTempWorkStr() -> String {
		if(self.blTempWork == "1"){
			return "是"
		}else{
			return "否"
		}
	}
	
	init() {
	}
}

///司机首页正在进行的发车req
struct UnFinishedReq:STRequest {
	var carCode:String
	
	var logicUrl: String{
		return "Dri/qryHomeSendTruckInfo.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let signStr = carCode.driverMd5Str()
		let base64str = carCode.base64Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


///司机首页发车登记的req
struct DriSendSignReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Dri/updateDriverTime.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.driverMd5Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


//MARK:- 下一站的经纬度
//下一站的经纬度模型
struct NexSiteLocModel:SimpleCodable {
	///纬度
	var latitude: String = ""
	///经度
	var longitude: String = ""
	
	init() {
	}
}



//下一站的经纬度req
struct NextLocReq:STRequest {
	var siteName:String
	var logicUrl: String{
		return "Emp/qrySiteLocation.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let signStr = siteName.employeeMdStr()
		let base64str = siteName.base64Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}



//到车提醒的req
struct ArriAlertReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Dri/insHomeCome.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.driverMd5Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


//密码修改req
struct DriInfoModReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Dri/updatePassWord.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.driverMd5Str()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}
