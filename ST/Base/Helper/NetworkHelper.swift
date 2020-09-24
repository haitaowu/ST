//
//  NetworkHelper.swift
//  ST
//
//  Created by taotao on 2019/9/12.
//  Copyright © 2019 HTT. All rights reserved.
//

import Foundation
import Alamofire

enum ReqStateType:Int {
    case reqSucc = 0, reqFail = 1
}

typealias ReqResBlock = (_ state:ReqStateType, _ data: Any) ->()

class NetworkHelper: NSObject {
	//单例的两种写法
//	static let shareInstance = NetworkHelper()
	static let shareInstance: NetworkHelper = {
		let instance = NetworkHelper()
		return instance
	}()
	
    private override init(){}

  /*  func POSTData<T>(stResponse: @escaping (NetResponse<T>) -> Void){
        let params:Parameters = [:];
        let url = "www.baidu.com"
        Alamofire.request(url, method: .post, parameters: params ).responseJSON {[unowned self] resp in
            var response:NetworkingResponse!
            if let httpResp = resp as? HTTPURLResponse{
                response = NetworkingResponse(httpCode: httpResp.statusCode, data: data, error: err,headers:httpResp.allHeaderFields)
            }else{
                response = NetworkingResponse(httpCode: 0, data: data, error: err,headers:[:])
            }
        }
 }
 */
    
    
    ///POST 请求
    static func POST(url: String, params: Parameters?, block:@escaping ReqResBlock){
        Alamofire.request(url, method: .post, parameters: params ).responseJSON {
			response in
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            let data = json.value(forKey: "data") ?? ""
                            block(ReqStateType.reqSucc,data)
                        }else{
                            let msg = json.value(forKey: "msg") ?? ""
                            block(ReqStateType.reqFail,msg)
                        }
                    }
                }else{
                    block(ReqStateType.reqFail,"")
                }
            }else{
                block(ReqStateType.reqFail,"")
            }
        }
    }
	
	
	///地址匹配
	static func FetchAddress(params: Parameters?, block: @escaping ReqResBlock){
		let url = "http://58.215.182.249:8015/SuTongSeperatesInterface/queryAddressDetailByAddress"
		Alamofire.request(url, method: .post, parameters: params ).responseJSON {
		  response in
		  if let json = response.result.value as? NSDictionary{
			if let stauts = json.value(forKey: "success"),let statusNum = stauts as? Int{
			  if statusNum == 1,let data = json.value(forKey: "data") as? Array<Dictionary<String,Any>> {
				block(.reqSucc,data)
			  }else{
				block(.reqFail,"没有查询到结果")
			  }
			}else{
			  block(.reqFail,"没有查询到结果")
			}
		  }else{
			block(.reqFail,"没有查询到结果")
		  }
		}
	}
	
	
	///si ji fa che deng shang chuan tupian
	static func uploadDriSignImgs(to urlStr: String, imgs: Array<UIImage>,block: @escaping ReqResBlock){
		let url = URL.init(string: Consts.UploadServer)
		guard let uploadUrl = url else{return}
		Alamofire.upload(multipartFormData: { (formData) in
			for (idx, img) in imgs.enumerated(){
				if let imgData = img.jpegData(compressionQuality: 0.5){
					let prefixName = Date().dateStringFrom(dateFormat: "yyyyMMddHHmmss")
					let imgName = "\(prefixName)_\(idx).jpeg"
					formData.append(imgData, withName: imgName, mimeType: "image/png")
				}
			}
		}, to: uploadUrl) { (encodingResult) in
			
			switch encodingResult{
			case .success(let upload,_,_):do{
				upload.responseJSON{
					response in
				}
				}
			case .failure(let error):do{
				}
			default:print("default")
			}
		}
		
	}
	
	
	
}


