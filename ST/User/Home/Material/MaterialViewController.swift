//
//  MaterialViewController.swift
//  ST
//
//  Created by taotao on 2017/8/27.
//  Copyright © 2017年 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire




class MaterialViewController: UIViewController,UITextFieldDelegate,WangdianPickerInterface {

    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var proposerField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var sumField: UITextField!
    @IBOutlet weak var remarkField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "物料申请";
        self.proposerField.text = Defaults["sitecode"].stringValue
        self.countField.addTarget(self, action: #selector(txtChange(sender:)), for: .editingChanged)
        self.priceField.addTarget(self, action: #selector(txtChange(sender:)), for: .editingChanged)
    }
    
    
    //MARK:- WangdianPickerInterface protocol
    func onWangdianPicked(item: SiteInfo) {
        self.siteField.text = item.siteName
    }
    
    //MARK:- private
    func timeStrWith(format:String) -> String{
        let dateFormat = DateFormatter.init();
        dateFormat.dateFormat = format;
        let date:Date = Date();
        let dateStr = dateFormat.string(from: date);
        return dateStr;
    }
    
    func pickSite() {
        self.showWangdianPicker();
    }
    
    //MARK:- selectors
    @objc func txtChange(sender:UITextField){
        let countStr = self.countField.text!
        let priceStr = self.priceField.text!
        if ((countStr.isEmpty == false) && (priceStr.isEmpty == false)) {
            let count = Float(countStr)!;
            let price = Float(priceStr)!;
            let sum = price * count;
            self.sumField.text = "\(sum)";
        }else{
           self.sumField.text = ""
        }
    }
    
    //选择品名
    @IBAction func tapProductBtn(_ sender: Any) {
        let vc = ProductsTableViewController(nibName: "ProductsTableViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        weak var weakSelf = self
        vc.selectBlock = {(product)-> () in
            if let name = product["GOODS_NAME"] as? String{
                NSLog("select product name \(name)")
                weakSelf?.nameField.text = name
                let params: Parameters = ["GOODS_NAME":name];
                weakSelf?.requestProductPrice(parameters: params)
            }
        }
    }
    
    
   

    //tap gesture
    @IBAction func tapOnView(_ sender: Any) {
        self.view.endEditing(true);
    }
    
    
    //点击申请
    @IBAction func tapOnRequestBtn(_ sender: Any) {
        
        let siteStr = self.siteField.text!
        if siteStr.isEmpty{
            self.remindUser(msg: "请选择站点");
            return;
        }
        
        let nameStr = self.nameField.text!
        if nameStr.isEmpty {
            self.remindUser(msg: "选择品名");
            return;
        }
        
        let countStr = self.countField.text!
        if countStr.isEmpty {
            self.remindUser(msg: "请输入数量");
            return;
        }
        
        let priceStr = self.priceField.text!
        if priceStr.isEmpty {
            self.remindUser(msg: "没有价格");
            return;
        }
        
        let sumStr = self.sumField.text!
        if sumStr.isEmpty {
            self.remindUser(msg: "没有总价");
            return;
        }
        
        let timeStr = self.timeStrWith(format:"yyyy-MM-dd hh:mm:ss");
        var rec: Parameters = [:];
        rec["USER_SITE"] =  siteStr
        rec["APPLY_DATE"] =  timeStr
        rec["APPLY_NAME"] =  nameStr
        rec["UNIT_MONEY"] = priceStr
        rec["APPLY_COUNT"] = countStr
        rec["SUM_MONEY"] = sumStr
        var params: Parameters = [:];
        do{
            let recData = try JSONSerialization.data(withJSONObject: [rec], options: .prettyPrinted)
            let recStr = String.init(data: recData, encoding: .utf8);
            if recStr != nil{
                params["rec"] = recStr
            }
        }catch{
            
        }
        NSLog("request product params = \(params)");
        self.submitProductRequest(parameters: params)
    }
    
   //MARK:- UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.remarkField{
            return true;
        }else if textField == self.siteField{
            self.pickSite();
            return false;
        }else if textField == self.countField{
            let name = self.nameField.text!;
            if name.isEmpty {
                self.remindUser(msg: "请选择品名")
                return false;
            }else{
                return true;
            }
        }else{
            return false;
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let countStr = textField.text!
        if countStr.isEmpty {
            return;
        }
        if textField == self.countField{
            let priceStr = self.priceField.text!;
            let name = self.nameField.text!;
            if name.isEmpty {
                self.remindUser(msg: "请选择品名")
                return;
            }
            
            if priceStr.isEmpty {
                self.remindUser(msg: "该品名没有价格")
                return;
            }
            
            let count = Float(countStr)!;
            let price = Float(priceStr)!;
            let sum = price * count;
            self.sumField.text = "\(sum)";
        }
        
    }
    
    //MARK:- request server
    //查询品名的价格
    func requestProductPrice(parameters: Parameters){
        let reqUrl = Consts.Server+Consts.BaseUrl+"m8/searchGoodPrice.do"
        NSLog("parameters = \(parameters)");
        Alamofire.request(reqUrl, method: .post, parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            self.priceField.text = ""
            if let json = response.result.value as? NSDictionary{
                if let data = json.value(forKey: "data"){
                    let dict = data as! NSDictionary;
                    if let price = dict.value(forKey: "SELL_PRICE"){
                        self.priceField.text = "\(price)";
                    }else{
                        self.priceField.text = "";
                    }
                }
            }
            self.txtChange(sender: self.priceField)
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }
    }
    //提交物料申请
    func submitProductRequest(parameters: Parameters){
        let reqUrl = Consts.Server+Consts.BaseUrl+"/uploadTabApply.do"
        NSLog("parameters = \(parameters)");
        Alamofire.request(reqUrl, method: .post, parameters: parameters).responseJSON { response in
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            self.remindUser(msg: "申请物料成功")
                        }else{
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "申请物料失败")
                }
            }else{
                self.remindUser(msg: "申请物料失败")
            }
        }
    }

}
