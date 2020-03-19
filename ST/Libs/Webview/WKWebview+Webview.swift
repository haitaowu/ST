//
//  WKWebview+AXWebview.swift
//  ST
//
//  Created by yunchou on 2016/11/15.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit
import WebKit
class WebView: UIView,AXWebviewContext {
    func loadUrl(url:String){
        if let url = URL(string: url){
            let req = URLRequest(url: url)
            self.wkWebView.load(req)
        }
    }
    func loadHtml(html:String){
        self.wkWebView.loadHTMLString(html, baseURL: nil)
    }
    func stopLoad(){
        self.wkWebView.stopLoading()
    }
    func reload(){
        self.wkWebView.reload()
    }
    func eval(js:String){
        self.wkWebView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    private var wkWebView:WKWebView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit(){
        let config = WKWebViewConfiguration()
        self.wkWebView = WKWebView(frame:self.bounds, configuration: config)
        self.addSubview(self.wkWebView)
        self.wkWebView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


