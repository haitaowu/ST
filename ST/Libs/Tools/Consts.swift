//
//  Consts.swift
//  ST
//
//  Created by yunchou on 2016/11/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

struct Consts {
	//    static var BaseUrl = "/AndroidService/m8"
	static var DriverKey = "4SF2gr5S5dftsAd5rB4E5pqxDsf5"
	static var EmpKey = "4SF2gr5S5dftsd5rB4E5pqxD5"
	static var BDNaviAK = "56VpYlxh8BNxaXCmb7G2Tcclfc1RkdFp"
	static var BDAIAK = "yPNcSgnD8ofsQIdHjr6lecdO"
	static var BDAISK = "lDMV2Vt6bhX8G87pK741Nv30GkwlEgSV"
	
	static var DriverAccKey = "DriverAccKey"
	static var DriverPwdKey = "DriverPwdKey"
	static var pwdCenterKey = "pwdCenterKey"
	
	#if DEBUG
	
	//测试环境的接口
	//1.服务器地址
	static var Server = "http://58.215.182.252:8610/"
	static var BaseUrl = "AndroidServiceSTIOS/"
	///2.测试：图片上传地址
	static var UploadServer = "http://58.215.182.252:8610/SuTongAppInterface/File/uploadFile.do"
	///3.图片下载地址测试
	static var ImgServer = "http://58.215.182.252:8070/download/"
	
	#else
	//生产环境的接口
	//1.
	static var Server = "http://58.215.182.251:5889/"
	static var BaseUrl = "AndroidService/"
	///2.图片下载地址生产环境
	static var ImgServer = "http://58.215.182.251:8070/download/"
	///3.正式：图片上传地址
	static var UploadServer = "http://58.215.182.251:5889/SuTongAppInterface/File/uploadFile.do"
	
	
	#endif
	

	//测试环境的接口
	//    static var Server = "http://58.215.182.251:5900/"
	
	//    static var BaseUrl9 = "SuTongAppInterface/"
	//    static var Host9 = "http://58.215.182.252:8610/"
	
}


