//
//  KuaijianChaxunViewController.swift
//  ST
//
//  Created by yunchou on 2016/10/29.
//  Copyright © 2016年 dajiazhongyi. All rights reserved.
//

import UIKit

class KuaijianChaxunViewController: UIViewController,QrInterface {
    @IBOutlet weak var tableView: UITableView!
    
    enum queryType {
        case problem,follow
    }
    
    @IBOutlet weak var yundanhaoField: UITextField!
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var topContainer: UIView!
    
    var billInfo: Dictionary<String,Any>?
    
    var billInfoKeys: Array<String>?
    
    var record:YundanChaxunRecord = YundanChaxunRecord()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBgColor
        self.topContainer.borderColor = UIColor.appLineColor
        self.topContainer.bottomBorderWidth = 0.5
        self.title = "快件查询"
        #if DEBUG
            self.yundanhaoField.text = "8000017719202"
        #endif
        
        self.billInfoKeys = ["registerDate,录单时间","sendSite,寄件几点","dispSite,目的网点","goodsName,物品名称","number,件数","weight,重量","blOverLong,超长标识","blOverWeight,超重标识","rbillCode,回单号"]
        
        //1.录单时间：2.寄件网点 3.目的网点 4.货物名称 5.件数 6.重量
        // Do any additional setup after loading the view.
    }
    
    func onReadQrCode(code:String){
        self.yundanhaoField.text = code
        self.chaxunBtnClicked(self)
    }
    
	private func makeHtml(type: queryType) -> String{
        let header = "<header><meta name=\"viewport\" content=\"width=device-width,height=device-height,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"><meta charset=\"utf-8\"/></header>"
		let contents = self.record.scan.map{
			var content = ""
			if type == .problem{
				if $0.content.contains("问题件"){
					content = "\($0.content)"
				}
			}else{
				if !$0.content.contains("问题件"){
					content = "\($0.content)"
				}
			}
			
			return "<div class='day' style='margin-bottom: 8px;'>\($0.day)</div><div class='scan' style=' border-left-color: rgba(0, 0, 0, 0.62); border-left-style: solid; border-left-width: 1px; padding-left: 6px; margin-left: 6px; color: rgba(0, 0, 0, 0.62); font-size: 14px;'><div class='time'>\($0.time)</div><div class='content'>\(content)</div></div>" }.joined(separator: "")
        let body = "<body>\(contents)</body>"
        return "<!DOCTYPE html><html>\(header)\(body)</html>"
    }
    
    
    
    private func reloadData(type: queryType){
		let html = self.makeHtml(type: type)
        self.webView.loadHtml(html: html)
    }
    
    // MARK: - SELECTORS
    @IBAction func saoBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    ///gen zong ji lu
    @IBAction func clickFollowBtn(_ sender: Any) {
        self.view.endEditing(true)
        let ydh = self.yundanhaoField.text ?? ""
        self.fetchBillInfo(billNum: ydh, type: .follow)
    }
    
    //wen ti jian
    @IBAction func chaxunBtnClicked(_ sender: Any) {
        self.view.endEditing(true)
        let ydh = self.yundanhaoField.text ?? ""
        self.fetchBillInfo(billNum: ydh, type: .problem)
    }


    
    // MARK: - request server
    func fetchBillInfo(billNum: String, type: queryType){
        if billNum.isEmpty{
            self.remindUser(msg: "运单号不能为空")
            return
        }
        if !billNum.isBarcode(){
            self.remindUser(msg: "运单号格式错误")
            return
        }
        let req = YundanChaxunRequest(ydh: billNum)
        self.showLoading(msg: "查询中...")
        STNetworking<YundanChaxunRecord>(stRequest:req){
            [unowned self]resp in
            self.hideLoading()
            NSLog("\(resp)")
            if resp.stauts == Status.Success.rawValue{
                self.record = resp.data
                if self.record.bill.count > 0{
                    self.billInfo = self.record.bill[0] as? Dictionary<String, Any>
                    self.tableView.reloadData()
                }
                if self.record.scan.count == 0{
                    self.remindUser(msg: "暂无查询结果")
                    return
                }
                self.reloadData(type: type)
            }else{
                self.remindUser(msg: resp.msg)
            }
        }?.resume()
    }


}


//MARK:- tableView delegate / datasouce
extension KuaijianChaxunViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.billInfoKeys?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resuseId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: resuseId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: resuseId)
        }
        
		if let billKeys = self.billInfoKeys?[indexPath.row]{
            let keyAry = billKeys.split(separator: ",")
            let key = keyAry[0]
            let title = keyAry[1]
            if var valStr = self.billInfo?["\(key)"]{
				if (key == "blOverWeight") || (key == "blOverLong"){
					valStr = (valStr as! String) == "1" ? "是" : "否"
				}
                let infoStr = "\(title):\(valStr)"
                cell?.textLabel?.text = infoStr
            }
        }
        
        return cell!
    }
    
    
        
}
