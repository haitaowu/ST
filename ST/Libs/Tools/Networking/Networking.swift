//
//  Networking.swift
//  Networking
//
//  Created by yunchou on 2016/10/31.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation
import Dispatch
enum HttpMethod{
    case get
    case post
    case put
    case delete
}

protocol Request{
    var host:String{get}
    var path:String{get}
    var headers:[String:String]{get}
    var querys:[AnyHashable:Any]{get}
    var bodyStream:InputStream? {get}
    var parameters:[AnyHashable:Any]{get}
    var charset:String.Encoding{get}
    var method:HttpMethod{get}
}

extension Request{
    var host:String{ return "" }
    var path:String{ return "" }
    var headers:[String:String]{ return [:]}
    var querys:[AnyHashable:Any]{ return [:] }
    var bodyStream:InputStream? {return nil}
    var parameters:[AnyHashable:Any]{return [:]}
    var files:[String:String]{ return [:] }
    var method:HttpMethod{return .get }
    var charset:String.Encoding{ return String.Encoding.utf8 }
}

protocol JsonRequest:Request {
}

extension JsonRequest{
    var bodyStream:InputStream? {
        guard let data = (try? JSONSerialization.data(withJSONObject: self.parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0))) else{
            return nil
        }
        if data.count > 0 {
            return InputStream(data:data)
        }
        return nil
    }
    var method:HttpMethod{
        return .post
    }
}

protocol FormRequest:Request {
}
extension FormRequest{
    var bodyStream:InputStream? {
        let encodeData = (self.parameters.map{
            let key = "\($0.key)".urlEncode()
            let value = "\($0.value)".urlEncode()
            return "\(key)=\(value)"
        }.joined(separator: "&").data(using: self.charset))
        guard let data = encodeData else{
                return nil
        }
        if data.count > 0{
            return InputStream(data:data)
        }
        return nil
    }
    var method:HttpMethod{
        return .post
    }
}

protocol Response{
    var httpCode:Int{get}
    var data:Data?{get}
    var error:Error?{get}
    var headers:[AnyHashable:Any]{get}
}
extension Response{
    func json() -> Any?{
        return try? JSONSerialization.jsonObject(with: data ?? Data(), options: JSONSerialization.ReadingOptions.allowFragments)
    }
    func decode<T>(decoder:(_ data:Data?) -> T?) -> T?{
        return decoder(self.data)
    }
    func text() -> String?{
        return String(data: data ?? Data(), encoding: String.Encoding.utf8)
    }
}

protocol Networking{
    init?(request:Request,onResponse:@escaping(Response) -> Void)
    func resume()
    func cancel()
}

struct NetworkingResponse:Response{
    var httpCode: Int = 0
    var data: Data? = nil
    var error: Error? = nil
    var headers:[AnyHashable:Any] = [:]
}

extension Request{
    var urlRequest:URLRequest?{
        let query = self.querys.map{
            let key = "\($0.key)".urlEncode()
            let value = "\($0.value)".urlEncode()
            return key + "=" + value
        }.joined(separator: "&")
        var urlStr = "\(self.host)\(self.path)"
        if !query.isEmpty{
            urlStr = "\(urlStr)?\(query)"
        }
        guard let url = URL(string:urlStr ) else{ return nil }
        let req = NSMutableURLRequest(url: url)
        req.allHTTPHeaderFields = self.headers
        req.httpBodyStream = self.bodyStream
        req.httpMethod = "\(self.method)"
        return req as URLRequest
    }
}

class UrlSessioinNetworking:Networking{
    private var session:URLSession = URLSession.shared
    private var task:URLSessionDataTask? = nil
    required init?(request:Request,onResponse:@escaping(Response) -> Void){
        guard let sreq = request.urlRequest else{
            return nil
        }
        self.task = session.dataTask(with: sreq, completionHandler: { (data, resp, err) in
            var response:NetworkingResponse!
            if let httpResp = resp as? HTTPURLResponse{
                response = NetworkingResponse(httpCode: httpResp.statusCode, data: data, error: err,headers:httpResp.allHeaderFields)
            }else{
                response = NetworkingResponse(httpCode: 0, data: data, error: err,headers:[:])
            }
            DispatchQueue.main.async {
                onResponse(response)
            }
        })
    }
    func resume() {
        task?.resume()
    }
    func cancel() {
        task?.cancel()
    }
}

extension String{
    public func urlEncode() -> String{
        let customAllowedSet =  NSCharacterSet(charactersIn:" ,!*'\"{}();:@&=+$,/?%#[]").inverted
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        return escapedString ?? ""
    }
}
