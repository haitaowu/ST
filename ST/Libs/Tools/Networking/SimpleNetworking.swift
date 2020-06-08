//
//  SimpleNetworking.swift
//  Networking
//
//  Created by yunchou on 2016/10/31.
//  Copyright © 2016年 Simplezhongyi. All rights reserved.
//

import Foundation
import HandyJSON

protocol SimpleCodableRequest:JsonRequest {
    associatedtype CodableObjectType:SimpleCodable
    var obj:CodableObjectType{get}
}

extension SimpleCodableRequest{
    var bodyStream: InputStream?{
        if let d = self.obj.encode(),d.count > 0{
            return InputStream(data: d)
        }
        return nil
    }
    var method:HttpMethod{
        return .post
    }
}


enum SimpleHttpError:Error{
    case DecodeError
}

extension Response{
    func decode<T:SimpleCodable>() -> T?{
        return T.decode(data: data)
    }
    
}

extension Array:SimpleCodable{
}

extension Dictionary:SimpleCodable{
}

extension String: SimpleCodable{}

protocol SimpleCodable:HandyJSON{
    static func decode(data:Data?) -> Self?
    func encode() -> Data?
}
extension SimpleCodable{
    static func decode(data:Data?) -> Self?{
        if let d = data,let text = String(data: d, encoding: String.Encoding.utf8){
            return JSONDeserializer<Self>.deserializeFrom(json: text)
        }
        return nil
    }
    func encode() -> Data?{
			if let s = self.toJSONString(){
            return s.data(using: String.Encoding.utf8)
        }
        return nil
    }
}


