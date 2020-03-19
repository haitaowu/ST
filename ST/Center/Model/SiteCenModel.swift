//
//  UserModel.swift
//  ST
//
//  Created by taotao on 2019/9/12.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation


//发车提醒信息货车信息模型
struct EmpSendCarModel:SimpleCodable {
	///描述
	var content: String = ""
	///操作时间
	var scanDate: String = ""
	init() {
	}
}

//发车提醒信息模型
struct EmpHomeSendModel:SimpleCodable {
	///车辆个数
	var count: String = ""
	///货车信息
	var homeInfo: [EmpSendCarModel] = []
	init() {
	}
}


///发车提醒信息的请求request
struct EmpHomSendReq:STRequest {
	var siteName:String
	var logicUrl: String{
		return "Emp/qryHomeInfo.do"
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



//中心、网点账号首页公告的模型
struct EmpHomAnno:SimpleCodable {
	///String    发布内容  [需要进行 base64 解码]
	var content: String = ""
	///操作时间
	var scanDate: String = ""
	
	///String     发布时间
	var noticeTime: String = ""
	
	///String     发布网点
	var person: String = ""
	///String     公告标题
	var title: String = ""
	
	init() {
	}
}


///中心、网点账号首页公告的请求request
struct EmpHomAnnoReq:STRequest {
	var siteName:String
	var logicUrl: String{
		return "Emp/qryHomeNoticeInfo.do"
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




//中心、网点、司机账户消息
struct AnnoModel:SimpleCodable {
    var content: String = ""
    var noticeTime: String = ""
    var person: String = ""
    var title: String = ""

    init() {
    }
}


///中心、网点账号的请求request
struct AnnounDataReq:STRequest {
	var params:[String:String]
    var logicUrl: String{
		return "Emp/findNotice.do"
    }
	
    var parameters: [AnyHashable : Any]{
		let paramsStr = params.jsonDicStr()
		let base64str = paramsStr.base64Str()
		let signStr = params.empMD5DataStr()
        return [
            "data":base64str,
            "sign":signStr,
        ]
    }
}

///中心、网点账号基础资料修改的请求request
struct UserInfoModReq:STRequest {
	var params:[String:String]
    var logicUrl: String{
		return "Emp/updatePassWord.do"
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






