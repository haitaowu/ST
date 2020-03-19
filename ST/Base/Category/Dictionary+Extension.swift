//
//  Dictionary+Extension.swift
//  ST
//
//  Created by taotao on 2019/9/17.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation


extension Dictionary{
    
    ///返回中心、网点请求参数data的md5加密字符串
    func empMD5DataStr() -> String {
        let jsonStr = self.jsonDicStr()
        return jsonStr.employeeMdStr()
    }
    
    ///返回司机请求参数data的md5加密字符串
    func driverMD5DataStr() -> String {
        let jsonStr = self.jsonDicStr()
        return jsonStr.driverMd5Str()
    }
    
    ///返回字典json格式字符串
    func jsonDicStr() -> String {
//        let jsonStr = JSONSerializer.serializeToJSON(object: self)
        let jsonStr = self.toJSONString()
        return jsonStr ?? ""
    }
    
}
