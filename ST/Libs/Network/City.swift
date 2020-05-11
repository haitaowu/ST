//
//  City.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation


struct City:SimpleCodable {
    var id:Int = 0
    var name:String = ""
    var fid:Int = 0
}

struct CityLoadRequest:STRequest{
    var logicUrl:String{
        return "/initCity.do"
    }
}


struct AddressModelRequest:STRequest {
    var path: String{
        return "QryDataInterface/queryCity.do"
    }
}

struct AddressPickerProvince:SimpleCodable {
    var province:String = ""
    var cityData:[AddressPickerCity] = []
    var selectCityIndex:Int = 0
}

struct AddressPickerCity:SimpleCodable {
    var city:String = ""
}
struct AddressPickerModel:SimpleCodable {
    var provincesList:[AddressPickerProvince] = []
    var selectProvinceIndex:Int = 0
}

extension AddressPickerModel:PickerInputViewModel{
    func componentsCount() -> Int{
        return 2
    }
    func rowCountForComponent(c:Int) -> Int{
        if c == 0 {
            return self.provincesList.count
        }else if c == 1{
            if self.provincesList.count > 0{
                return self.provincesList[selectProvinceIndex].cityData.count
            }else{
                return 0;
            }
        }
        return 0
    }
	
    func titleForRow(row:Int,component:Int) -> String{
        if component == 0 {
            return self.provincesList[row].province
        }else if component == 1{
            return self.provincesList[selectProvinceIndex].cityData[row].city
        }
        return ""
    }
    
    func getCurrentAddress() -> String{
        let p = self.provincesList[selectProvinceIndex]
        if p.cityData.count > 0{
            let c = p.cityData[p.selectCityIndex]
            return "\(p.province)-\(c.city)"
        }
        return p.province
    }
}
