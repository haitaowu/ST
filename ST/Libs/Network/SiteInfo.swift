//
//  SiteInfo.swift
//  ST
//
//  Created by yunchou on 2016/11/5.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation


struct SiteInfo:SimpleCodable {
    var siteCode:String = ""
    var siteName:String = ""
    var superiorSite:String = ""
    var ModifyDate:String = ""
}

struct SiteInfoLoadRequest:STRequest {
    var logicUrl: String{
        return "/initSite.do"
    }
}


