//
//  DriverModel.swift
//  ST
//
//  Created by taotao on 2019/9/19.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation



//MARK:- 堵车
//堵车模型
struct HeavyRecModel:SimpleCodable {
	//(String)  路由
	var lineName: String = ""
	//(String)  清单编号
	var linkCode: String = ""
	//(String)  发车时间
	var sendDate: String = ""
	//(String)  堵车流水号(用于详情查询的参数）
	var truckCode: String = ""
}

//堵车报备列表
struct HeavyRecReq:STRequest {
	var params: [String: String]
	var logicUrl: String{
		return "Dri/qryJam.do"
	}
	
	var parameters: [AnyHashable : Any]{
//		        let params = ["damageJamCode":carNum]
		let paramsStr = params.jsonDicStr()
		let mdSignStr = paramsStr.driverMd5Str()
		let base64Str = paramsStr.base64Str()
		return [
			"data":base64Str,
			"sign":mdSignStr
		]
	}
	
}

//堵车报备详情模型
struct HeavDetailModel:SimpleCodable {
	///(String)  纬度
	var latitude: String = ""
	///(String)  经度
	var longtiude: String = ""
	///(String)  当前状态
	var endScanType: String = ""
	///(String)  清单编号
	var linkCode: String = ""
	///(String)  实时图片
	var jamPic: String = ""
	///(String)  导航路况信息图（导航截图
	var navigationUrl: String = ""
	///(String)   堵车原因
	var trafficJamReason: String = ""
	///(String)  堵车流水号
	var truckCode: String = ""
	///(String)  视频1地址
	var vido1Url: String = ""
}


//堵车报备详情
struct HeavyDetailReq:STRequest {
	var carNum:String
	var logicUrl: String{
		return "Dri/qryJamDetails.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let params = ["damageJamCode":carNum]
		let paramsStr = params.jsonDicStr()
		
		let mdSignStr = paramsStr.driverMd5Str()
		let base64Str = paramsStr.base64Str()
		return [
			"data":base64Str,
			"sign":mdSignStr
		]
	}
}



//堵车报备request
struct HeavyReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Dri/registerTrafficJam.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.driverMd5Str()
		return [
			"data":base64str,
			"sign":signStr
		]
	}
	
}



//MARK:- 车损列表模型
struct DamRecModel:SimpleCodable {
	//(String)  路由
	var lineName: String = ""
	//(String)  清单编号
	var listCode: String = ""
	//(String)  发车时间
	var sendDate: String = ""
	//(String)  车牌号
	var trucknum: String = ""
	//(String) 车损流水号(用于详情查询的参数）
	var vehicleDamageCode: String = ""
}


//车损报备列表
struct DamageRecReq:STRequest {
	var params: [String: String]
	var logicUrl: String{
		return "Dri/qryDamage.do"
	}
	
	var parameters: [AnyHashable : Any]{
		
//		let params = ["damageJamCode":carNum]
		let paramsStr = params.jsonDicStr()
		let mdSignStr = paramsStr.driverMd5Str()
		let base64Str = paramsStr.base64Str()
		return [
			"data":base64Str,
			"sign":mdSignStr
		]
	}
}


//车损报备详情模型
struct DamaDetailModel:SimpleCodable {
	
	//(String)   车损流水号
	var vehicleDamageCode: String = ""
	//(String) 清单号
	var listCode: String = ""
	
	//(String)   经度
	var longtiude: String = ""
	//(String)   纬度
	var latitude: String = ""
	//(String)  维修方式
	var repairType: String = ""
	//(String)  维修地点
	var repairAddress: String = ""
	//(String)  维修时常
	var repairTime: String = ""
	//(String)  车损图片地址
	var damageUrl: String = ""
	//(String)  实拍图片地址
	var liveActionPic: String = ""

	init() {
	}
}

//MARK:- 司机的请求request
struct AnnoDriverDataReq:STRequest {
	var params:[String:String]
	var logicUrl: String{
		return "Dri/qryNotice.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = params.driverMD5DataStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}



//MARK:- 车损报备详情Request
struct DamaDetailReq:STRequest {
	var damCode:String
	var logicUrl: String{
		return "Dri/qryDamageDetails.do"
	}
	
	var parameters: [AnyHashable : Any]{
		
		let params = ["damageJamCode":damCode]
		let paramsStr = params.jsonDicStr()
		let mdSignStr = paramsStr.driverMd5Str()
		let base64Str = paramsStr.base64Str()
		return [
			"data":base64Str,
			"sign":mdSignStr
		]
	}
}



////车损报备详情请求request
struct DamaVanReq:STRequest {
	var params:[String:String]
	var logicUrl: String{
		return "Dri/registerDamageCar.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.driverMd5Str()
		return [
			"data":base64str,
			"sign":signStr
		]
	}
}



//MARK:- 查询车牌信息模型
struct TruckNumModel:SimpleCodable {
	
	//(String)   班车名称
	var truckName: String = ""
	//(String) 车牌号
	var truckNum: String = ""
	//(String)   车主
	var truckOwer: String = ""
	//(String)   电话
	var phone: String = ""
	//(String)  行驶路线
	var truckLine: String = ""
	//(String)  车型
	var truckModels: String = ""
	//(String)  备注
	var remark: String = ""

	init() {
	}
}

///车牌信息模型的请求request
struct TruckNumMDataReq:STRequest {
	var siteName:String
	var logicUrl: String{
		return "Emp/findTruckInfo.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let base64str = siteName.base64Str()
		let signStr = siteName.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}

//MARK:- 路由信息模型
struct TruckRouteModel:SimpleCodable {
	
	///路由编号
	var lineCode: String = ""
	/// 路由名称
	var lineName: String = ""
	///始发站
	var sendSite: String = ""
	///到达站
	var comeSite: String = ""
	///经停站1
	var stopSite1: String = ""
	///经停站2
	var stopSite2: String = ""
	///经停站3
	var stopSite3: String = ""
	
	init() {
	}
}

///路由信息模型的请求request
struct TruckRouteMDataReq:STRequest {
	var siteName:String
	var logicUrl: String{
		return "Emp/findLineInfo.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let base64str = siteName.base64Str()
		let signStr = siteName.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


//挂车数据模型
struct TrailTruckModel:SimpleCodable {
	///挂车号
	var truckCarNum: String = ""
	init() {
	}
	
}

///挂车数据模型的请求request
struct TrailTruckDataReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Emp/qryTruckCarNum.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}

//MARK:- 发车
struct SendTruckInfoModel:SimpleCodable {
	
	///是否始发站
	var bl_state: String = ""
	/// 到达站
	var comeSite: String = ""
	///最新上下站
	var endPreNextStation: String = ""
	///最新扫描网点
	var endScanSite: String = ""
	///最新状态
	var endScanType: String = ""
	///路由code
	var lineCode: String = ""
	///路由
	var lineName: String = ""
	///始发站
	var sendSite: String = ""
	///封签号（后)
	var sendsealScanAhead: String = ""
	///	 封签号（后侧）
	var sendsealScanBackDoor: String = ""
	///封签号（前侧）
	var sendsealScanMittertor: String = ""
	///经停站1
	var stopSite1: String = ""
	///经停站2
	var stopSite2: String = ""
	///经停站3
	var stopSite3: String = ""
	/// 挂车号
	var truckCarNum: String = ""
	/// 车型
	var trucktype: String = ""
	init() {
	}
}

///根据车牌查询发车的请求request
struct SendTruckInfoReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Emp/findStartCar.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


//发车登记的request
struct SendCarSignReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Emp/registerStartCar.do"
	}
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr
		]
	}
	
}


//到车信息模型
struct SendTruckModel:SimpleCodable {
	
	///是否为外派加班车
	var blTempWork: String = ""
	/// 发车时间
	var starTime: String = ""
	/// 挂车号
	var truckCarNum: String = ""
	/// 车型
	var truckType: String = ""
	/// 路由
	var lineName: String = ""

	init() {
	}
	
}

///到车信息模型的请求request
struct ArriTruckMDataReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Emp/findArriveCar.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}


///到车登记的request
struct ArriTruckSignReq:STRequest {
	var params:[String: String]
	var logicUrl: String{
		return "Emp/registerArriveCar.do"
	}
	
	
	var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = paramsStr.employeeMdStr()
		return [
			"data":base64str,
			"sign":signStr,
		]
	}
}
