//
//  BillPrintTableController.swift
//  ST
//  Created by taotao on 20/03/2018.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire


class SubBillQueryController:UITableViewController,QrInterface {
   //MARK:- IBOutlets
    @IBOutlet var containerViewCollect: [HTDashView]!
    @IBOutlet weak var billNumField: UITextField!
    @IBOutlet weak var sendSiteField: UITextField!
    @IBOutlet weak var destAdrField: UITextField!
    @IBOutlet weak var transferCenterField: UITextField!
    @IBOutlet weak var detailAdrTxtView: CustomTextView!
    @IBOutlet weak var sendGoodsTypeField: UITextField!
    @IBOutlet weak var goodsNameField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var queryBtn: UIButton!
    

    var billInfo:NSDictionary  = NSDictionary();
    
    //MARK:- override mothods
    override func viewDidLoad() {
        self.setupUI();
		
		
    }
    
    //MARK:- update ui methods
    func updateUIWithBillInfo(queryBillInfo:NSDictionary) -> Void {
        
        if let sendSite = queryBillInfo["sendSite"] as? String{
            self.sendSiteField.text = sendSite
        }
        
        if let arriveSite = queryBillInfo["arriveSite"] as? String{
            self.destAdrField.text = arriveSite
        }
        
        if let transferCenter = queryBillInfo["dispatchCenter"] as? String{
            self.transferCenterField.text = transferCenter
        }
        
        if let acceptManAddress = queryBillInfo["acceptManAddress"] as? String{
            self.detailAdrTxtView.text = acceptManAddress
        }
        
        if let sendgoodsType = queryBillInfo["sendgoodsType"] as? String{
            self.sendGoodsTypeField.text = sendgoodsType
        }
        
        if let goodsName = queryBillInfo["goodsName"] as? String{
            self.goodsNameField.text = goodsName
        }
        
        if let weight = queryBillInfo["weight"]{
            let weightStr = "\(weight)";
            self.weightField.text = weightStr
        }
        
        if let pieceNumber = queryBillInfo["pieceNumber"] {
            let pieceNumberStr = "\(pieceNumber)"
            self.countField.text = pieceNumberStr
        }
    }
    
    
    //MARK:- private methods
    func setupUI() {
        self.title = "子单打印";
        self.submitBtn.layer.cornerRadius = 5;
        self.submitBtn.layer.masksToBounds = true;
        self.detailAdrTxtView.placeholder = "输入地址";
//        self.sendSiteField.text = DataManager.shared.loginUser.siteName;
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated);
//        for  view in self.containerViewCollect {
//            view.setupDashLine();
//        }
//    }

    
    //MARK:- selectors
    @IBAction func tapPrinterBtn(_ sender: Any) {
        if billInfo.allKeys.count <= 0 {
            self.remindUser(msg: "请输入运单号查询")
            return;
        }
        let connViewControl = PrinterPreviewController(nibName: "PrinterPreviewController", bundle: nil)
        connViewControl.billInfo = self.billInfo;
//        let billCode = self.billNumField.text!
//        connViewControl.billSN = billCode;
        self.navigationController?.pushViewController(connViewControl, animated: true);
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    //点击查询运单详情按钮
    @IBAction func tapQuery(_ sender: Any) {
        self.view .endEditing(true)
        
        var rec: Parameters = [:];
        
        let billCode = self.billNumField.text!
        if billCode.isEmpty{
            self.remindUser(msg: "请输入运单号");
            return;
        }else{
//			if billCode.isValidateBillNum(){
			rec["billCode"] = billCode
//            }else{
//                self.remindUser(msg: "运单号格式不正确");
//                return;
//            }
        }
        self.queryBillWith(params: rec);
    }
    
    //MARK:- request server
    //根据运单号查询运单详情
    func queryBillWith(params:Parameters) {
        self.showLoading(msg: "查询单中...");
        let reqUrl = Consts.Server + Consts.BaseUrl + "m8/qryBillSub.do"
        Alamofire.request(reqUrl, method: .post, parameters: params).responseJSON {[unowned self] response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            self.remindUser(msg: "查询成功")
                            let data = json.value(forKey: "data") as? NSArray;
                            if let billData = data?.firstObject as? NSDictionary{
                                self.updateUIWithBillInfo(queryBillInfo: billData);
                                self.billInfo = billData;
                            }
                        }else{
                            let msg = json.value(forKey: "msg") as? String
                            self.remindUser(msg: msg!)
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "查询失败")
                }
            }else{
                self.remindUser(msg: "查询失败")
            }
        }
    }
    
    func onReadQrCode(code: String) {
        self.billNumField.text = code
    }
	
    
    //MARK:- UITableView dataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath);
        cell.backgroundColor = UIColor.clear;
        return cell;
    }
    
    //MARK:- UITableView delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001;
    }
    
    //MARK:- UIScrollView delegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true);
    }
}
