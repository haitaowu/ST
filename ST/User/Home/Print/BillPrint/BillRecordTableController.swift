//
//  BillPrintTableController.swift
//  ST
//  Created by taotao on 20/03/2018.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire


class BillRecordTableController:UITableViewController,QrInterface,WangdianPickerInterface {
   //MARK:- IBOutlets
    @IBOutlet var containerViewCollect: [HTDashView]!
    @IBOutlet weak var sendSiteField: UITextField!
    @IBOutlet weak var sendDateField: UITextField!
    @IBOutlet weak var billNumField: UITextField!
    @IBOutlet weak var expressTypeBtn: UIButton!
    @IBOutlet weak var destAdrField: UITextField!
    @IBOutlet weak var receSiteTxtView: CustomTextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var goodsNameField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var expressBtn: UIButton!
	@IBOutlet weak var fetchBillBtn: UIButton!
    
    let billInfo:NSMutableDictionary  = NSMutableDictionary();
    
    //MARK:- override mothods
    override func viewDidLoad() {
        self.setupUI();
    }
    
    //MARK:- private methods
    func setupUI() {
        self.title = "单件录入";
        for  view in self.containerViewCollect {
            view.setupDashLine();
        }
		fetchBillBtn.addCorner(radius: 5, color: UIColor.red, borderWidth: 1)
        self.submitBtn.layer.cornerRadius = 5;
        self.submitBtn.layer.masksToBounds = true;
        self.receSiteTxtView.placeholder = "输入地址";
        self.sendDateField.text = Date().dateStringFrom(dateFormat: "yyyy-MM-dd hh:mm:ss")
        self.sendSiteField.text = DataManager.shared.loginUser.siteName;
    }
    
  
    
    func showSubmitSuccView() -> Void {
        HTAlertViewPrint.ShowAlertViewWith(printBlock: {[unowned self] in
            self.showConnPrinterView();
        }) {
            
        };
    }
    
    func showConnPrinterView() -> Void {
        let connViewControl = PrinterPreviewController(nibName: "PrinterPreviewController", bundle: nil)
//        connViewControl.billInfo = self.billInfo;
        let billCode = self.billNumField.text!
        connViewControl.billSN = billCode;
        self.navigationController?.pushViewController(connViewControl, animated: true);
    }
    
    
    
    //MARK:- selectors
    @IBAction func tapSubmitBtn(_ sender: Any) {
//        self.showSubmitSuccView();
//        return;
        
        var Rec: Parameters = [:];
        let registerDate = self.sendDateField.text!
        if registerDate.isEmpty{
            self.remindUser(msg: "请选择日期");
            return;
        }else{
            Rec["registerDate"] = registerDate
            billInfo["registerDate"] = registerDate;
        }
        
        let SITE_NAME = self.sendSiteField.text!
        if SITE_NAME.isEmpty{
            self.remindUser(msg: "请选择网点名称");
            return;
        }else{
            Rec["sendSite"] = SITE_NAME;
            billInfo["sendSite"] = SITE_NAME;
        }
        
        let billCode = self.billNumField.text!
        if billCode.isEmpty{
            self.remindUser(msg: "请输入运单号");
            return;
        }else{
			if billCode.isValidateBillNum(){
                Rec["billCode"] = billCode
                billInfo["billCode"] = billCode;
            }else{
                self.remindUser(msg: "运单号格式不正确");
                return;
            }
        }
        
        let acceptManAddress = self.receSiteTxtView.text!
        if acceptManAddress.isEmpty{
            self.remindUser(msg: "请输入收件地址");
            return;
        }else{
            Rec["acceptManAddress"] = acceptManAddress
            billInfo["acceptManAddress"] = acceptManAddress;
        }
        
        let arriveSite = self.destAdrField.text!
        if arriveSite.isEmpty{
            self.remindUser(msg: "请输入目的网点");
            return;
        }else{
            Rec["arriveSite"] = arriveSite
            billInfo["arriveSite"] = arriveSite;
        }
        
        let sendgoodsType = self.expressBtn.title(for: .normal)!
        if sendgoodsType.isEmpty{
            self.remindUser(msg: "请选择送货方式");
            return;
        }else{
            Rec["sendgoodsType"] = sendgoodsType
        }
        
        let goodsName = self.goodsNameField.text!
        if goodsName.isEmpty{
            self.remindUser(msg: "请输入物品名称");
            return;
        }else{
            Rec["goodsName"] = goodsName
            billInfo["goodsName"] = goodsName;
        }
        
        let weight = self.weightField.text!
        if weight.isEmpty{
            self.remindUser(msg: "请输入实际重量");
            return;
        }else{
            Rec["weight"] = weight
            billInfo["weight"] = weight;
        }
        
        let pieceNumber = self.countField.text!
        if pieceNumber.isEmpty{
            self.remindUser(msg: "请输入件数");
            return;
        }else{
            Rec["pieceNumber"] = pieceNumber
            billInfo["pieceNumber"] = pieceNumber;
        }
        
        var params: Parameters = [:];
        do{
            let recData = try JSONSerialization.data(withJSONObject: [Rec], options: .prettyPrinted)
            let recStr = String.init(data: recData, encoding: .utf8);
            if recStr != nil{
                params["rec"] = recStr
            }
        }catch{
        }
        
        self.submitBillInfoWith(params: params);
    }
    
    @IBAction func tapExpressBtn(_ sender: Any) {
        let array = ["派送","自提"];
        self.view.endEditing(true);
        HTAlertConfirmView .ShowAlertViewWithTitles(titles: array) {[unowned self] (title:String) ->Void in
            print("hello baby \(title)");
            self.expressBtn.setTitle(title, for: .normal)
        }
    }
    
    @IBAction func wangdianBtnClicked(_ sender: Any) {
        self.showWangdianPicker()
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
	
	@IBAction func clickFetchBillNum(){
		print("获取单号。。。")
		self.requestBillNum()
	}
    
    //MARK:- request server
	//app获取电子面单接口
	func requestBillNum(){
		self.showLoading(msg: "查询中...")
		let req = BillNumReq()
		STNetworking<String>(stRequest: req) {
			[unowned self] (resp) in
			self.hideLoading()
			if resp.stauts == Status.Success.rawValue{
				self.billNumField.text = resp.data
			}else if resp.stauts == Status.NetworkTimeout.rawValue{
				self.remindUser(msg: "网络超时，请稍后尝试")
			}else{
				let msg = resp.msg
				self.remindUser(msg: msg)
			}
		}?.resume()
		
		
		//		let baseUrl = "AndroidServiceST-M8/"
		//		let reqUrl = Consts.Server + baseUrl + "m8/getElectronic.do"
//		let reqUrl = "http://58.215.182.252:8119/AndroidServiceST-M8/m8/getElectronic.do"
//		STHelper.POST(url: reqUrl, params: nil) {
//			[unowned self](result, data) in
//			self.hideLoading()
//			if (result == .reqSucc) {
//				if let billCode = data as? String{
//					self.billNumField.text = billCode
//				}
//			}else{
//				guard let msg = data as? String else {
//					return
//				}
//				self.remindUser(msg: msg)
//			}
//		}
	}
	
	
    //提交录单数据
    func submitBillInfoWith(params:Parameters) {
        self.showLoading(msg: "提交保单中...");
        let reqUrl = Consts.Server + Consts.BaseUrl + "m8/uploadPrintBillSubNew.do"
        Alamofire.request(reqUrl, method: .post, parameters: params).responseJSON {[unowned self] response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            if let json = response.result.value as? NSDictionary{
                if let stauts = json.value(forKey: "stauts"){
                    if let statusNum = stauts as? Int{
                        if statusNum == 4{
                            self.remindUser(msg: "保存成功")
                            let data = json.value(forKey: "data") as? NSArray;
                            if let billData = data?.firstObject as? NSDictionary{
                                let transferCenter = billData["transferCenter"];
                                print("transferCenter = \(String(describing: transferCenter))");
                                self.billInfo["transferCenter"] = billData["transferCenter"];
                                self.showSubmitSuccView();
                            }
                        }else{
                            let msg = json.value(forKey: "msg") as? String
                            self.remindUser(msg: msg!)
                            NSLog("request product status = \(stauts)")
                        }
                    }
                }else{
                    self.remindUser(msg: "保存失败")
                }
            }else{
                self.remindUser(msg: "保存失败")
            }
        }
    }
    
    //MARK:- WangdianPickerInterface
    func onWangdianPicked(item:SiteInfo){
        self.destAdrField.text = item.siteName
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
