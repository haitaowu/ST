//
//  FinancialController.swift
//  ST
//
//  Created by taotao on 2017/9/11.
//  Copyright © 2017年 dajiazhongyi. All rights reserved.
//


import UIKit
import Alamofire

class FinancialController: UIViewController ,UITextFieldDelegate,WangdianPickerInterface{

    @IBOutlet weak var operationSiteField: UITextField!
    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var operaterField: UITextField!
    @IBOutlet weak var financialField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var sumField: UITextField!
    @IBOutlet weak var orderNumField: UITextField!
    @IBOutlet weak var remarkField: UITextField!
    
    //MARK:- override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "财务充值"
        self.operationSiteField.text = Defaults["sitecode"].stringValue
        self.operaterField.text = Defaults["username"].stringValue
    }
    
    
    //tap gesture
    @IBAction func tapOnView(_ sender: Any) {
        self.view.endEditing(true);
    }
    
    
    //MARK:- private 
    func pickSite() {
        self.showWangdianPicker();
    }
    
//    func timeStrWith(format:String) -> String{
//        let dateFormat = DateFormatter.init();
//        dateFormat.dateFormat = format;
//        let date:Date = Date();
//        let dateStr = dateFormat.string(from: date);
//        return dateStr;
//    }
    
    //MARK:- WangdianPickerInterface protocol
    func onWangdianPicked(item: SiteInfo) {
        self.siteField.text = item.siteName
        self.queryFinancialWithSite(site: item.siteName)
    }
    
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.orderNumField || textField == self.remarkField || textField == self.sumField {
            return true
        }else{
            return false
        }
    }
    
    //MARK:- selectors
    @IBAction func tapOneSiteBtn(_ sender: Any) {
        self.pickSite()
    }
    //点击申请
    @IBAction func tapOnRequestBtn(_ sender: Any) {
        
        var Rec: Parameters = [:];
        let SITE_NAME = self.siteField.text!
        if SITE_NAME.isEmpty{
            self.remindUser(msg: "请选择网点名称");
            return;
        }else{
            Rec["SITE_NAME"] = SITE_NAME
        }
        
        let CENTER_NAME = self.financialField.text!
        if CENTER_NAME.isEmpty {
            self.remindUser(msg: "选择账务中心");
            return;
        }else{
            Rec["CENTER_NAME"] = CENTER_NAME
        }
        
        let BALANCE_CUR_MONEY = self.sumField.text!
        if BALANCE_CUR_MONEY.isEmpty {
            self.remindUser(msg: "输入金额");
            return;
        }else{
            Rec["BALANCE_CUR_MONEY"] = BALANCE_CUR_MONEY
        }
        
        
        let BILL_CODE = self.orderNumField.text!
        if BILL_CODE.isEmpty {
            self.remindUser(msg: "请输入运单号");
            return;
        }else{
            Rec["BILL_CODE"] = BILL_CODE
        }
        
        let BALANCE_TYPE = self.typeField.text!
        if BALANCE_TYPE.isEmpty == false {
            Rec["BALANCE_TYPE"] = BALANCE_TYPE
//            self.remindUser(msg: "运单号");
//            return;
        }else{
//            Rec["BALANCE_TYPE"] = BALANCE_TYPE
        }
        
        let REMARK = self.remarkField.text!
        if REMARK.isEmpty {
            self.remindUser(msg: "请输入备注");
            return;
        }else{
            Rec["REMARK"] = REMARK
        }
        
//        let ID = self.timeStrWith(format:"hhmmss");
		let ID = Date().dateStringFrom(dateFormat: "hhmmss")
        
        Rec["ID"] = ID
        var params: Parameters = [:];
        do{
            let recData = try JSONSerialization.data(withJSONObject: [Rec], options: .prettyPrinted)
            let recStr = String.init(data: recData, encoding: .utf8);
            if recStr != nil{
                params["rec"] = recStr
            }
        }catch{
        }
        self.submitFinancialRequestWith(params: params)
    }

    
    //MARK:- request server 
    //提交充值请求
    func submitFinancialRequestWith(params:Parameters) {
        let reqUrl = Consts.Server+Consts.BaseUrl+"m8/uploadBalanceDetail.do"
        NSLog("parameters = \(params)");
        Alamofire.request(reqUrl, method: .post, parameters: params).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            self.remindUser(msg: "充值申请成功")
                        }else{
                            let msg = json.value(forKey: "msg") as? String
                            self.remindUser(msg: msg!)
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "充值申请失败")
                }
            }else{
                self.remindUser(msg: "充值申请失败")
            }
        }
    }
    
    //根据网点名称查询账务中心
    func queryFinancialWithSite(site:String) {
        let reqUrl = Consts.Server+Consts.BaseUrl+"m8/searchSiteFinanceCenter.do"
        var params: Parameters = [:];
        params["siteName"] =  site
        
        NSLog("parameters = \(params)");
        Alamofire.request(reqUrl, method: .post, parameters: params).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            self.financialField.text = ""
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            if let data = json.value(forKey: "data"){
                                let financialCenterStr = data as! String;
                                self.financialField.text = financialCenterStr
                            }
                        }else{
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "申请物料失败")
                }
            }
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }

    
}
