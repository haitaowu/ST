//
//  UserModel.swift
//  ST
//
//  Created by taotao on 2019/9/12.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation

//中心、网点用户消息
struct RespMsg :SimpleCodable{
     var msg: String = ""
     var stauts: Int = -1
}

//请求验证码
struct AuthCodeReq:STRequest {
    var phone:String
    var roleType:RoleType
    
    var logicUrl: String{
        if self.roleType == RoleType.driver {
            return "Dri/insMessage.do"
        }else{
            return "Emp/insMessage.do"
        }
    }
    
    var parameters: [AnyHashable : Any]{
        
        var mdStr:String
        if self.roleType == RoleType.driver {
            mdStr = phone.driverMd5Str()
        }else{
            mdStr = phone.employeeMdStr()
        }
        return [
					"data":phone.base64Str(),
            "sign":mdStr
        ]
    }
}


//修改密码
struct ResetPwdReq:STRequest {
    var params:[String:String]
    var roleType:RoleType
    
    var logicUrl: String{
        if self.roleType == RoleType.driver {
            return "Dri/updDri.do"
        }else{
            return "Emp/updEmp.do"
        }
    }
    
    var parameters: [AnyHashable : Any]{

			let dataStr = params.jsonDicStr()
        var mdStr:String
        if self.roleType == RoleType.driver {
            mdStr = dataStr.driverMd5Str()
        }else{
            mdStr = params.empMD5DataStr()
        }
        return [
            "data":dataStr.base64Str(),
            "sign":mdStr
        ]
    }
    
    
}

