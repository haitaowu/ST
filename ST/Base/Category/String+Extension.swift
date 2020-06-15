//
//  NSString+Extension.swift
//  ST
//
//  Created by taotao on 2019/7/11.
//  Copyright © 2019 dajiazhongyi. All rights reserved.
//

import Foundation

extension String{
    ///计算字符串的高度
    func strHeightWith(font: UIFont, limitWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: limitWidth, height: CGFloat(MAXFLOAT))
        let rect = NSString(string: self).boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        let height = rect.size.height + 8 * 2
        return height
    }

	
    func nsRangeOf(txt: String) -> NSRange? {
        guard let ran = range(of: txt) else{
            return NSRange(location: 0,length: 0)
        }
        
        if let startIdx = ran.lowerBound.samePosition(in: utf16),let toIdx = ran.upperBound.samePosition(in: utf16){
            let loc = utf16.distance(from: utf16.startIndex, to: startIdx)
            let len = utf16.distance(from: startIdx, to: toIdx)
            return NSRange(location: loc,length: len)
        }else{
            return NSRange(location: 0,length: 0)
        }
    }
	
	///给指定的字符添加指定的颜色
	func attriStr(highlightStr: String, color: UIColor) -> NSAttributedString{
		let mutAttri = NSMutableAttributedString.init(string: self)
		if let range = self.nsRangeOf(txt: highlightStr){
			mutAttri.addAttributes([.foregroundColor:color], range: range)
		}
		return mutAttri
	}
    
    ///检查是否为正确的手机格式
    func isPhoneNum()-> Bool{
        let regexStr = "^^1[0-9][0-9]\\d{8}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regexStr)
        return predicate.evaluate(with: self)
    }
	
	///base64 encoding string
	func base64Str()-> String{
		let data = self.data(using: .utf8)
		if let base64str = data?.base64EncodedString(){
			return base64str
		}else{
			return ""
		}
	}
	
	///base64 decoding string
	func decode4String()->String{
		if let data = Data(base64Encoded: self){
			let string = String(data: data, encoding: .utf8) ?? ""
			return string
		}
		return ""
	}
	
	///base64 zip decoding string
	func decodeZip64String()->String{
		if let comporessData = Data(base64Encoded: self){
			let data = comporessData.gzipUncompress()
			let string = String(data: data, encoding: .utf8) ?? ""
			return string
		}
		return ""
	}
	
	
	///转换当前字符串为指定格式的日期对象，如果不指定格式则为默认的格式
	func dateOf(format:String = "yyyy-MM-dd HH:mm:ss") -> Date {
		let dateFormat = DateFormatter()
		dateFormat.timeZone = TimeZone.current
		dateFormat.locale = Locale.init(identifier: "zh_CN")
		dateFormat.dateFormat = format
		let date = dateFormat.date(from: self)
		if let d = date{
			return d
		}else{
			return Date()
		}
	}
	
	
	///验证运单号是否正确
    func isValidateBillNum() -> Bool {
        let regexStr = "^(((66|77|88|99)[0-9]{7})|((8)[0-9]{12})|((2)[0-9]{10}))$";
        let predicate = NSPredicate(format: "SELF MATCHES %@", regexStr);
        let isValid = predicate.evaluate(with: self);
        return isValid;
    }
	
    
}
