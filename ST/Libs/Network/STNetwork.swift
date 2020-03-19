//
//  NetResponse.swift
//  ST
//
//  Created by yunchou on 2016/11/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

protocol STRequest:FormRequest {
    var baseUrl:String{ get }
    var logicUrl:String{ get }
}

extension STRequest{
    var host:String{
        return Consts.Server
    }
    var baseUrl:String{ return Consts.BaseUrl }
    var logicUrl:String{ return "" }
    var path:String{
        return "\(self.baseUrl)\(self.logicUrl)"
    }
    var headers:[String:String]{
        return ["Content-Type":"application/x-www-form-urlencoded;charset=utf-8"]
    }
    
}

protocol STUploadRequest:STRequest {
    associatedtype CodableObjectType:SimpleCodable
    var obj:CodableObjectType{get}
    var parameterKey:String{get}
}

extension STUploadRequest{
    var parameterKey:String{ return ""}
    var parameters:[AnyHashable:Any]{
        if let jsondata = obj.encode(){
            if let str = String(data: jsondata, encoding: String.Encoding.utf8){
                return [self.parameterKey:str]
            }
        }
        return [:]
    }
}
enum Status:Int {
    case NetworkTimeout = -1
    case MissingParameter = 2
    case PasswordWrong = 3
    case Success = 4
}

struct NetResponse<T:SimpleCodable>:SimpleCodable {
    var stauts:Int =  -1
    var data:T = T()
    var msg:String = ""
}


class STNetworking<T:SimpleCodable>:UrlSessioinNetworking{
    init?(stRequest: Request, stResponse: @escaping (NetResponse<T>) -> Void) {
        super.init(request: stRequest){
            resp in
            if let stresp:NetResponse<T> = resp.decode(){
                stResponse(stresp)
            }else{
                stResponse(NetResponse<T>())
            }
        }
    }
    
    required init?(request: Request, onResponse: @escaping (Response) -> Void) {
        super.init(request: request, onResponse: onResponse)
    }
}


struct STImageUploadRequest:Request {
    var target:String
    var imagePath:String
    var boundary:String{
        return "__aixinyunchou__"
    }
    
    var bodyStream: InputStream?{
        var data = Data()
        let url = URL(fileURLWithPath: self.imagePath)
        let fileName = url.lastPathComponent
        let contentType = "image/png"
        guard let imageData = (try? Data(contentsOf: url))else{ return nil }
        data.append("--\(boundary)\r\nContent-Disposition:form-data; name=file; filename=\(fileName)\r\nContent-Type:\(contentType)\r\n\r\n".data(using: String.Encoding.utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--".data(using: String.Encoding.utf8)!)
        if data.count > 0{
            return InputStream(data: data)
        }
        return nil
    }
    
    var headers:[String:String]{
        return ["Content-Type":"multipart/form-data; charset=utf-8; boundary=\(boundary)"]
    }
    var method:HttpMethod{
        return .post
    }
    var host:String{
        return Consts.Server
    }
    var path:String{
        return target
    }
}
