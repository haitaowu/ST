//
//  PrintModels.swift
//  ST
//
//  Created by taotao on 2020/6/8.
//  Copyright © 2020 HTT. All rights reserved.
//

import Foundation

struct TransportType: SimpleCodable{
	let classCode: String = ""
	let className: String = ""
	init() {
	}
	
}


struct TransportReq: STRequest{
	var logicUrl: String  {
		return "m8/getClasses.do"
	}
}



struct AdrModel: SimpleCodable{
	var town: String = ""
	var city: String = ""
	var province: String = ""
	
	subscript(key: AdrKey) -> String{
		switch key{
		case .town:
			return self.town
		case .city:
			return self.city
		case .province:
			return self.province
		}
	}
}


struct AddressReq: STRequest{
	let adrModel: AdrModel
	var logicUrl: String  {
		return "m8/getProvinceCityTown.do"
	}
	
	var parameters: [AnyHashable : Any]{
		var params = [AnyHashable: Any]()
		if !adrModel.province.isEmpty {
			params[AdrKey.province.rawValue] = adrModel.province
		}
		if !adrModel.city.isEmpty {
			params[AdrKey.city.rawValue] = adrModel.city
		}
		if !adrModel.town.isEmpty {
			params[AdrKey.town.rawValue] = adrModel.town
		}
		return params
	}
	
}





