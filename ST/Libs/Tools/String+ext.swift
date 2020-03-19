//
//  String+ext.swift
//  ST
//
//  Created by yunchou on 2016/12/1.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation
import Regex

extension String{
    func md5() -> String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
//        result.deallocate(capacity: digestLen)
        result.deallocate()
        return String(format: hash as String)
    }
	
    func stPasswrod() -> String{
        return ("+-%@)10F87F61-38E3-44BE-95AB-BCFE95982544}D&^klkd*" + String(self.characters.reversed())).md5().uppercased()
    }
	
    func isBarcode() -> Bool{
        let config = Regex(/*"[0-9]{12}"*/"[0-9]*")
        return config.matches(self)
    }
    
    //网点、员工、中心账号的md5
     func employeeMdStr() -> String{
        let strs = self + Consts.EmpKey
        return strs.signStr()
    }
    
    //司机账号的md5
    func driverMd5Str() -> String{
        let strs = self + Consts.DriverKey
        return strs.signStr()
    }
    
    //给String字符串签名
    func signStr() -> String {
        let strs = self
        let str = strs.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(strs.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return String(format: hash as String)
    }
   
    
    
    
    
}
