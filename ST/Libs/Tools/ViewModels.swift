//
//  ShoujianModel.swift
//  ST
//
//  Created by yunchou on 2016/11/7.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

protocol STListViewModel {
    var columnNames:[String]{get}
}
struct UploadResult:SimpleCodable {
    
}
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
    var logicUrl: String{
        return "/uploadRec.do"
    }
}

struct FajianModel {
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
    var logicUrl: String{
        return "/uploadSend.do"
    }
}
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
    var logicUrl: String{
        return "/uploadCome.do"
    }
}



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
    var logicUrl: String{
        return "/uploadDisp.do"
    }
}

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
    var logicUrl: String{
        return "/uploadSign.do"
    }
}

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
    var logicUrl: String{
        return "/uploadProblem.do"
    }
}
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
        return "/searchBill.do"
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
        return "/searchSite.do"
    }
    var parameters: [AnyHashable : Any]{
        return [
            "prov":prov,
            "city":city,
            "word":word
        ]
    }
}

struct AccountMoney:SimpleCodable{
    var ConfirmMoney:String = ""
}
struct AccountMoneySearchRequest:STRequest {
    var siteName:String = ""
    var logicUrl: String{
        return "/searchAcountMoney.do"
    }

    var parameters: [AnyHashable : Any]{
        return ["siteName":self.siteName]
    }
}
