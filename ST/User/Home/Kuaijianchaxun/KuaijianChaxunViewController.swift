//
//  KuaijianChaxunViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class KuaijianChaxunViewController: UIViewController,QrInterface {
    @IBOutlet weak var yundanhaoField: UITextField!
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var topContainer: UIView!
    var record:YundanChaxunRecord = YundanChaxunRecord()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor
        self.topContainer.borderColor = UIColor.appLineColor
        self.topContainer.bottomBorderWidth = 0.5
        self.title = "快件查询"
        #if DEBUG
            self.yundanhaoField.text = "100030745322"
        #endif
        // Do any additional setup after loading the view.
    }
    func onReadQrCode(code:String){
        self.yundanhaoField.text = code
        self.chaxunBtnClicked(self)
    }
    private func makeHtml() -> String{
        let header = "<header><meta name=\"viewport\" content=\"width=device-width,height=device-height,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"><meta charset=\"utf-8\"/></header>"
        let contents = self.record.scan.map{ "<div class='day' style='margin-bottom: 8px;'>\($0.day)</div><div class='scan' style=' border-left-color: rgba(0, 0, 0, 0.62); border-left-style: solid; border-left-width: 1px; padding-left: 6px; margin-left: 6px; color: rgba(0, 0, 0, 0.62); font-size: 14px;'><div class='time'>\($0.time)</div><div class='content'>\($0.content)</div></div>" }.joined(separator: "")
        let body = "<body>\(contents)</body>"
        return "<!DOCTYPE html><html>\(header)\(body)</html>"
    }
    
    @IBAction func saoBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    private func reloadData(){
        let html = self.makeHtml()
        self.webView.loadHtml(html: html)
    }
    
    @IBAction func chaxunBtnClicked(_ sender: Any) {
        self.view.endEditing(true)
        let ydh = self.yundanhaoField.text ?? ""
        
        if ydh.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !ydh.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        let req = YundanChaxunRequest(ydh: ydh)
        self.showLoading(msg: "查询中...")
        STNetworking<YundanChaxunRecord>(stRequest:req){
            [unowned self]resp in
            self.hideLoading()
            NSLog("\(resp)")
            if resp.stauts == Status.Success.rawValue{
                self.record = resp.data
                if self.record.scan.count == 0{
                    self.remindUser(msg: "暂无查询结果")
                    return
                }
                self.reloadData()
            }else{
                self.remindUser(msg: resp.msg)
            }
        }?.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
