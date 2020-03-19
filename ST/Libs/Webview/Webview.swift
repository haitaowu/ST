//
//  AXWebview.swift
//  ST
//
//  Created by yunchou on 2016/11/15.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import Foundation

protocol AXWebviewDelegate {
}
extension AXWebviewDelegate{
    func onMessage(ctx:AXWebviewContext,msg:String){}
    func onLoadBegin(ctx:AXWebviewContext){}
    func onLoadProgress(ctx:AXWebviewContext,progress:Float){}
    func onLoadError(ctx:AXWebviewContext,error:Error){}
    func onLoadComplete(ctx:AXWebviewContext){}
}

@objc protocol AXWebviewContext {
    func loadUrl(url:String)
    func stopLoad()
    func reload()
    func eval(js:String)
}
