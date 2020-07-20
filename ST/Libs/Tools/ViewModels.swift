//
//  ShoujianModel.swift
//  ST
//
//  Created by yunchou on 2016/11/7.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation
import HandyJSON



protocol STListViewModel {
	var columnNames:[String]{get}
}

///没有数据返回情况下
struct UploadResult:SimpleCodable {
}

///没有数据返回情况下
struct ReqResult:SimpleCodable {
}


//MARK:- 收件
struct ShoujianModel {
	var billCode:String = ""
	var recMan:String = ""
	var scanDate:String = ""
}

extension ShoujianModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,recMan]
	}
}
extension ShoujianModel:SimpleCodable{}
struct ShoujianSaveRequest:STUploadRequest {
	var obj:[ShoujianModel]
	var parameterKey:String{ return "rec" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadRec.do"
	}
}

//MARK:- 发件
struct FajianModel{
	var billCode:String = ""
	var preOrNext:String = ""
	var scanDate:String = ""
	var classs:String = ""
}

extension FajianModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,preOrNext]
	}
}
extension FajianModel:SimpleCodable{}
struct FajianSaveRequest:STUploadRequest {
	var obj:[FajianModel]
	var parameterKey:String{ return "send" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadSend.do"
	}
}

//MARK:- 到件
struct DaojianModel {
	var billCode:String = ""
	var preOrNext:String = ""
	var scanDate:String = ""
}

extension DaojianModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,preOrNext]
	}
}
extension DaojianModel:SimpleCodable{}
struct DaojianSaveRequest:STUploadRequest {
	var obj:[DaojianModel]
	var parameterKey:String{ return "come" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadCome.do"
	}
}



//MARK:- 派件
struct PaijianModel {
	var billCode:String = ""
	var dispMan:String = ""
	var scanDate:String = ""
}

extension PaijianModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,dispMan]
	}
}

extension PaijianModel:SimpleCodable{}
struct PaijianSaveRequest:STUploadRequest {
	var obj:[PaijianModel]
	var parameterKey:String{ return "disp" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadDisp.do"
	}
}

//MARK:- 签收
struct QianshouModel {
	var billCode:String = ""
	var signName:String = ""
	var tp:String = ""
	var signRemark:String = ""
	var signDate:String = ""
}


extension QianshouModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,signName,tp.isEmpty ? "否":"是"]
	}
}


extension QianshouModel:SimpleCodable{}

struct QianshouSaveRequest:STUploadRequest {
	var obj:[QianshouModel]
	var parameterKey:String{ return "sign" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadSign.do"
	}
}

//MARK:- 运单号是否到件和录单
///request
struct OrderValiReq:STRequest {
	var billCode:String
	var logicUrl: String{
		return "m8/qryCome.do"
	}
	
	var parameters: [AnyHashable : Any]{
		return [
			"billCode":billCode
		]
	}
}



//MARK:- 问题件
struct WentijianModel {
	var billCode:String = ""
	var problemType:String = ""
	var sendSite:String = ""
	var problemReasion:String = ""
}

extension WentijianModel:STListViewModel{
	var columnNames:[String]{
		return [billCode,problemType]
	}
}
extension WentijianModel:SimpleCodable{}
struct WentijianSaveRequest:STUploadRequest {
	var obj:[WentijianModel]
	var parameterKey:String{ return "problem" }
	var parameters:[AnyHashable:Any]{
		if let str = obj.toJSONString(){
			return [parameterKey:str]
		}else{
			return [:]
		}
	}
	var logicUrl: String{
		return "m8/uploadProblem.do"
	}
}


//MARK:- 区域
struct QuyuModel:SimpleCodable {
	var siteName:String = ""
	var prov:String  = ""
	var manager:String = ""
	var principal:String = ""
	var dispatchRange:String = ""
	var tel:String = ""
	var siteCode:String  = ""
	var notdispatchRange:String = ""
}

extension QuyuModel:STListViewModel{
	var columnNames:[String]{
		return [prov,siteName,tel]
	}
}

//MARK:- 运单查询
struct YundanChaxunScan {
	var scanDate:String = ""
	var content:String = ""
	var day:String{
		let cmp = scanDate.components(separatedBy: " ")
		return cmp.first ?? ""
	}
	var time:String{
		let cmp = scanDate.components(separatedBy: " ")
		return cmp.last ?? ""
	}
}
extension YundanChaxunScan:SimpleCodable{}
struct YundanChaxunRecord {
	var bill:[Any] = []
	var problem:[Any] = []
	var scan:[YundanChaxunScan] = []
}
extension YundanChaxunRecord:SimpleCodable{}
struct YundanChaxunRequest:STRequest {
	var ydh:String = ""
	var logicUrl: String{
		return "m8/searchBill.do"
	}
	var parameters: [AnyHashable : Any]{
		return ["billCode":self.ydh]
	}
}

struct QuyuChaxunRequest:STRequest {
	var prov:String = ""
	var city:String = ""
	var word:String = ""
	var logicUrl:String{
		return "m8/searchSite.do"
	}
	var parameters: [AnyHashable : Any]{
		return [
			"prov":prov,
			"city":city,
			"word":word
		]
	}
}

//MARK:- accountmoney
struct AccountMoney:SimpleCodable{
	var ConfirmMoney:String = ""
}
struct AccountMoneySearchRequest:STRequest {
	var siteName:String = ""
	var logicUrl: String{
		return "m8/searchAcountMoney.do"
	}
	
	var parameters: [AnyHashable : Any]{
		return ["siteName":self.siteName]
	}
}
