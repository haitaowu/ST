//
//  BillPrintTableController.swift
//  ST
//  Created by taotao on 20/03/2018.
//  Copyright © 2018 dajiazhongyi. All rights reserved.
//

import UIKit
import Alamofire


class MasterBillQueryController:UITableViewController,QrInterface,WangdianPickerInterface {
   //MARK:- IBOutlets
    @IBOutlet var containerViewCollect: [HTDashView]!
    @IBOutlet weak var billNumField: UITextField!
  
    @IBOutlet weak var masterBillNumField: UITextField!
    @IBOutlet weak var destSiteField: UITextField!
    @IBOutlet weak var addressField: UITextField!
  
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var fetchBillBtn: UIButton!
    
	
	var billInfo: Dictionary<String, Any>?
	
    
    //MARK:- override mothods
    override func viewDidLoad() {
        self.setupUI();
    }
    
	//MARK:- private methods
	func setupUI() {
		self.title = "主单打印";
		self.view.addDismissGesture()
		for  view in self.containerViewCollect {
			view.setupDashLine()
		}
		self.submitBtn.layer.cornerRadius = 5;
		self.submitBtn.layer.masksToBounds = true;
		fetchBillBtn.addCorner(radius: 5, color: UIColor.red, borderWidth: 1)
	}
	
	

	///显示打印机连接界面
	func showConnPrinterView() -> Void {
		
		if let info = self.billInfo{
			let connViewControl = MasterBillPrinter(nibName: "MasterBillPrinter", bundle: nil)
			connViewControl.billInfo = info
			self.navigationController?.pushViewController(connViewControl, animated: true);
		}
	}
	
	
	func updateUIBy(billInfo: Dictionary<String, Any>){
		//1.主单号
		if let billCode = billInfo["BILL_CODE"] as? String{
			self.billNumField.text = billCode
			self.masterBillNumField.text = billCode
		}
		
		//2.目的网点 DESTINATION(目的地)
		if let destination = billInfo["DESTINATION"] as? String{
			self.destSiteField.text = destination
		}
		
		//3.详细地址 ACCEPT_MAN_ADDRESS(收件人地址)
		var address = ""
		if let adrDetail = billInfo["ACCEPT_MAN_ADDRESS"] as? String{
			address = address + adrDetail
		}
		self.addressField.text = address
		//5.重量
		if let weight = billInfo["SETTLEMENT_WEIGHT"]{
			let weihtStr = "\(weight)"
			
			self.weightField.text = weihtStr
		}
		//6.件数
		if let piece = billInfo["PIECE_NUMBER"]{
			let pieceStr = "\(piece)"
			self.countField.text = pieceStr
		}
	}
    
    
    //MARK:- selectors
		///	点击查询运单信息按钮
	@IBAction func fetchBillInfo(_ sender: Any) {
		self.view.endEditing(true)
		var params: Parameters = [:];
		
		let billCode = self.billNumField.text!
		if billCode.isEmpty{
			self.remindUser(msg: "请输入运单号");
			return;
		}else{
//			if billCode.isValidateBillNum(){
			params["billCode"] = billCode
//			}else{
//				self.remindUser(msg: "运单号格式不正确");
//				return;
//			}
		}
		self.fetchBillDetailInfo(params: params)
	}
	
	
    ///点击打印按钮
	@IBAction func toPrinter(_ sender: Any) {
		#if DEBUG
		let info: [String : Any] = ["BILL_CODE": "5700165655793",
		"SEND_DATE": "2020-07-07 06:56:23",
		"PIECE_NUMBER": 1,
		"DESTINATION": "南宫市",
		"REGISTER_SITE": "衢州",
		"DISPATCH_SITE": "南宫市",
		"VOLUME_WEIGHT": 400.0,
		"SETTLEMENT_WEIGHT": 400.0,
		"FREIGHT": 2.0,
		"TOPAYMENT": 2.0,
		"PAYMENT_TYPE": "现金",
		"CUSTOMER_NAME": "",
		"SEND_MAN": "寄件人",
		"SEND_MAN_PHONE": "1876466949",
		"SEND_MAN_ADDRESS": "寄件地址",
		"ACCEPT_MAN": "收件人",
		"ACCEPT_MAN_PHONE": "158764648848",
		"ACCEPT_MAN_ADDRESS": "寄件地址",
		"DISPATCH_MODE": "派送",
		"REGISTER_MAN": "衢州",
		"SEND_FINANCE_CENTER": "华东财务中心",
		"DISPATCH_FINANCE_CENTER": "华北财务中心",
		"BL_RETURN_BILL": 0,
		"GOODS_NAME": "名称",
		"INSURANCE": 2.000200033187866,
		"R_BILLCODE": "",
		"BILL_CODE_SUB1": ";57001656557930001;",
		"OTHER_FEE": 2.0,
		"ID_CODE": "",
		"BL_MESSAGE": 0,
		"PACK_TYPE": "袋装",
		"PROVINCE": "江苏省",
		"CITY": "无锡市",
		"BOROUGH": "梅村",
		"PROVINCE_NAME": "上海",
		"CITY_NAME": "上海市",
		"COUNTY_NAME": "奉贤区",
		"BILL_WEIGHT": 2.0,
		"CLASS_TYPE": "汽运",
		"VOLUME": 2.0,
		"INSURED_MONEY": 0.0,
		"SENDGOODS_FEE": 31.0,
		"INSURE_VALUE": 20002.0,
		"BL_OVER_LONG": 0,
		"BL_OVER_WEIGHT": 0,
		"OVER_WEIGHT_PIECE": 0,
		"DESTINATION_CENTER": "石家庄分拨中心",
		"SCAN_SITE3": "金华分拨中心",
		"BL_MESSAGE1": 0,
		"BL_INTO_WAREHOUSE": 0,
		"OVER_AREA_FEE": 1.0,
		"UPSTAIRS_FEE": 2.0,
		"MANAGE_FEE": 2.0,
		"STORAGENO": "",
		"BILL_CODE_SUB": ";57001656557930001;",
		"TRANSFER_CENTER": "",
		"BL_ELECTRON": 1]
		self.billInfo = info
		#endif
		
		guard self.billInfo != nil else {
			self.remindUser(msg: "请查询运单")
			return
		}
		self.showConnPrinterView()
	}
	
	
    @IBAction func wangdianBtnClicked(_ sender: Any) {
        self.showWangdianPicker()
    }
    
    @IBAction func scanBtnClicked(_ sender: Any) {
        self.openQrReader()
    }
    
    //MARK:- request server
  
	//查询运单信息
    func fetchBillDetailInfo(params: Parameters){
      //billCode
      self.showLoading(msg: "查询中运单信息...")
      let reqUrl = Consts.Server + Consts.BaseUrl + "m8/getbillData.do"
      NetworkHelper.POST(url: reqUrl, params: params) {
        [unowned self](result, data) in
        self.hideLoading()
        if (result == .reqSucc) {
          if let billInfo = data as? Dictionary<String,Any>{
			self.billInfo = billInfo
			self.updateUIBy(billInfo: billInfo)
          }
        }else{
          guard let msg = data as? String else {
            return
          }
          self.remindUser(msg: msg)
        }
      }
    }
    
    
    //MARK:- WangdianPickerInterface
    func onWangdianPicked(item:SiteInfo){
//        self.destAdrField.text = item.siteName
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
    
	
}


/*
let info: [String : Any] = ["BILL_CODE": "5700165655793",
"SEND_DATE": "2020-07-07 06:56:23",
"PIECE_NUMBER": 1,
"DESTINATION": "南宫市",
"REGISTER_SITE": "衢州",
"DISPATCH_SITE": "南宫市",
"VOLUME_WEIGHT": 400.0,
"SETTLEMENT_WEIGHT": 400.0,
"FREIGHT": 2.0,
"TOPAYMENT": 2.0,
"PAYMENT_TYPE": "现金",
"CUSTOMER_NAME": "",
"SEND_MAN": "寄件人",
"SEND_MAN_PHONE": "1876466949",
"SEND_MAN_ADDRESS": "寄件地址",
"ACCEPT_MAN": "收件人",
"ACCEPT_MAN_PHONE": "158764648848",
"ACCEPT_MAN_ADDRESS": "寄件地址",
"DISPATCH_MODE": "派送",
"REGISTER_MAN": "衢州",
"SEND_FINANCE_CENTER": "华东财务中心",
"DISPATCH_FINANCE_CENTER": "华北财务中心",
"BL_RETURN_BILL": 0,
"GOODS_NAME": "名称",
"INSURANCE": 2.000200033187866,
"R_BILLCODE": "",
"BILL_CODE_SUB1": ";57001656557930001;",
"OTHER_FEE": 2.0,
"ID_CODE": "",
"BL_MESSAGE": 0,
"PACK_TYPE": "袋装",
"PROVINCE": "江苏省",
"CITY": "无锡市",
"BOROUGH": "梅村",
"PROVINCE_NAME": "上海",
"CITY_NAME": "上海市",
"COUNTY_NAME": "奉贤区",
"BILL_WEIGHT": 2.0,
"CLASS_TYPE": "汽运",
"VOLUME": 2.0,
"INSURED_MONEY": 0.0,
"SENDGOODS_FEE": 31.0,
"INSURE_VALUE": 20002.0,
"BL_OVER_LONG": 0,
"BL_OVER_WEIGHT": 0,
"OVER_WEIGHT_PIECE": 0,
"DESTINATION_CENTER": "石家庄分拨中心",
"SCAN_SITE3": "金华分拨中心",
"BL_MESSAGE1": 0,
"BL_INTO_WAREHOUSE": 0,
"OVER_AREA_FEE": 1.0,
"UPSTAIRS_FEE": 2.0,
"MANAGE_FEE": 2.0,
"STORAGENO": "",
"BILL_CODE_SUB": ";57001656557930001;",
"TRANSFER_CENTER": "",
"BL_ELECTRON": 1]
*/
