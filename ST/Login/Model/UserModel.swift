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
            "data":phone,
            "sign":mdStr
        ]
    }
}


//修改密码
struct ResetPwdReq:STRequest {
    var authCode:String
    var passWord:String
    var phone:String
    var roleType:RoleType
    
    var logicUrl: String{
        if self.roleType == RoleType.driver {
            return "Dri/updDri.do"
        }else{
            return "Emp/updEmp.do"
        }
    }
    
    var parameters: [AnyHashable : Any]{
        let dic = self.paramsDic()
        var mdStr:String
        if self.roleType == RoleType.driver {
            mdStr = dic.driverMD5DataStr()
        }else{
            mdStr = dic.empMD5DataStr()
        }
        return [
            "data":dic.jsonDicStr(),
            "sign":mdStr
        ]
    }
    
    
    func paramsDic() -> [AnyHashable:Any]{
        var dic = ["authCode":self.authCode]
        dic["passWord"] = self.passWord
        dic["phone"] = self.phone
        return dic
    }
    
}

